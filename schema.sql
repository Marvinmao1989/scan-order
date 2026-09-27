-- =====================================================
-- 扫码点餐 · 数据库初始化脚本
-- 使用方法：Supabase 控制台 → SQL Editor → 全部粘贴 → Run（可重复运行）
-- =====================================================

-- 1) 图片存储桶（菜品图 / 收款码图）
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do nothing;

-- 2) 数据表
create table if not exists categories (
  id bigint generated always as identity primary key,
  name text not null,
  sort int default 0,
  status int default 1,
  created_at timestamptz default now()
);

create table if not exists dishes (
  id bigint generated always as identity primary key,
  category_id bigint references categories(id) on delete cascade,
  name text not null,
  price numeric(10,2) not null,
  description text default '',
  image_url text default '',
  status int default 1,
  sort int default 0,
  created_at timestamptz default now()
);

create table if not exists orders (
  id bigint generated always as identity primary key,
  table_no text not null,
  note text default '',
  total numeric(10,2) not null,
  status int default 1,       -- 1 新订单 2 制作中 3 已完成 0 已取消
  pay_status int default 0,   -- 0 未支付 1 已支付
  created_at timestamptz default now()
);

create table if not exists order_items (
  id bigint generated always as identity primary key,
  order_id bigint references orders(id) on delete cascade,
  dish_name text not null,    -- 存菜品名快照，菜单改了也不影响历史订单
  price numeric(10,2) not null,
  qty int not null
);

create table if not exists settings (
  id int primary key,
  shop_name text default '我的小店',
  announcement text default '',
  collection_code_url text default ''
);

-- 3) 行级安全（RLS）：顾客只能读菜单、提交订单；店主（登录用户）可管理一切
alter table categories enable row level security;
alter table dishes enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table settings enable row level security;

drop policy if exists "公开读分类" on categories;
create policy "公开读分类" on categories for select to anon using (true);
drop policy if exists "公开读菜品" on dishes;
create policy "公开读菜品" on dishes for select to anon using (true);
drop policy if exists "公开读设置" on settings;
create policy "公开读设置" on settings for select to anon using (true);
drop policy if exists "顾客可下单" on orders;
create policy "顾客可下单" on orders for insert to anon with check (true);
drop policy if exists "顾客可加明细" on order_items;
create policy "顾客可加明细" on order_items for insert to anon with check (true);

drop policy if exists "店主全权订单" on orders;
create policy "店主全权订单" on orders for all to authenticated using (true) with check (true);
drop policy if exists "店主全权明细" on order_items;
create policy "店主全权明细" on order_items for all to authenticated using (true) with check (true);
drop policy if exists "店主全权分类" on categories;
create policy "店主全权分类" on categories for all to authenticated using (true) with check (true);
drop policy if exists "店主全权菜品" on dishes;
create policy "店主全权菜品" on dishes for all to authenticated using (true) with check (true);
drop policy if exists "店主全权设置" on settings;
create policy "店主全权设置" on settings for all to authenticated using (true) with check (true);

-- 4) 图片存储访问策略（公开可看，仅店主可传/删）
drop policy if exists "公开读图片" on storage.objects;
create policy "公开读图片" on storage.objects for select to anon using (bucket_id = 'images');
drop policy if exists "店主传图片" on storage.objects;
create policy "店主传图片" on storage.objects for insert to authenticated with check (bucket_id = 'images');
drop policy if exists "店主删图片" on storage.objects;
create policy "店主删图片" on storage.objects for delete to authenticated using (bucket_id = 'images');

-- 5) 默认店铺设置（之后可在「菜单管理 → 设置」里修改）
insert into settings (id, shop_name, announcement, collection_code_url)
values (1, '我的小店', '欢迎光临，扫码点餐更方便', '')
on conflict (id) do nothing;

-- 6) 示例分类（不需要可以删除：菜单管理 → 分类 → 删除）
insert into categories (name, sort, status)
values ('招牌推荐', 1, 1), ('特色小吃', 2, 1);
