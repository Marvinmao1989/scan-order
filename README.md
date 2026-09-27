# 扫码点餐系统（H5 · 全免费）部署指南

一个文件搞定店内扫码点餐：顾客微信扫码 → 网页点餐下单；店主在接单台实时收单、确认收款。**不依赖微信小程序、无需认证、零费用**（用 Supabase 免费数据库 + Vercel/GitHub Pages 免费托管）。

## 系统包含

| 入口 | 地址 | 用途 |
|---|---|---|
| 点餐页 | `scan-order.html`（默认，带 `?t=桌号`） | 顾客扫码点餐、下单、付款指引 |
| 接单台 | `#/admin` | 店主登录后实时收单：确认收款 / 开始制作 / 完成 |
| 菜单管理 | `#/manage` | 店主登录后管理菜品、分类、店名公告、收款码 |

所有改动即时生效，顾客端刷新即看到。

---

## 部署步骤（约 40 分钟）

### 第 1 步：注册 GitHub（若已有可跳过）
打开 github.com 注册账号，用于存放网页代码。

### 第 2 步：创建 Supabase 数据库（免费）

1. 打开 supabase.com → 注册/登录 → **New Project**（Free 免费档）→ 创建完成后进入项目
2. 左侧 **Project Settings → API**：复制 **Project URL**（形如 `https://fntnhbbggpkyzdbuygsw.supabase.co/rest/v1/`）和 **anon public key**（sb_publishable_H8MI75k0EnYMFIC2JFmJdg_l9OQGCZ_）
3. 用文本编辑器（记事本即可）打开 `scan-order.html`，把这两项填到文件顶部 `CONFIG` 里，保存：

```js
const CONFIG = {
  SUPABASE_URL: 'https://你的项目.supabase.co',
  SUPABASE_ANON_KEY: '你的anon-key'
};
```

4. 左侧 **SQL Editor** → New Query → 把 `schema.sql` 的全部内容粘贴进去 → **Run**（自动建好表、权限和示例分类）
5. 左侧 **Authentication → Users → Add user**：用你的邮箱和密码创建**店主账号**（接单台和菜单管理登录用，请勿泄露密码）

### 第 3 步：部署网页（免费托管，免备案）

**方式 A：Vercel（推荐）**
1. 在 GitHub 新建一个仓库（如 `scan-order`），把 `scan-order.html` 和 `schema.sql`、`README.md` 一起上传
2. 打开 vercel.com → 用 GitHub 登录 → **Add New Project** → Import 刚才的仓库 → Deploy
3. 完成后得到网址：`https://xxx.vercel.app/scan-order.html`

> 想让顾客访问更短（根路径直达 `https://xxx.vercel.app/`）？部署前把 `scan-order.html` 改名为 `index.html` 再上传，二维码内容相应用 `https://xxx.vercel.app/?t=1`。

**方式 B：GitHub Pages**
仓库 Settings → Pages → Source 选 main 分支 → 得到 `https://用户名.github.io/仓库名/scan-order.html`。

### 第 4 步：生成桌码并打印

1. 打开[草料二维码](https://cli.im)（免费）
2. 内容填你的网址加桌号参数，每桌一个：`https://xxx.vercel.app/scan-order.html?t=1`、`?t=2`、`?t=3`…
3. 分别生成二维码，打印成 A6 不干胶，贴到对应桌角

### 第 5 步：手机真机测试

1. 手机微信扫桌码 → 应直接打开点餐页，顶部显示桌号
2. 加菜 → 去下单 → 提交 → 看到订单号和金额
3. 电脑/平板打开 `网址#/admin` → 用店主账号登录 → 应看到新订单并听到提示音
4. 到 `#/manage` 添加几个真实菜品、上传菜品图和收款码图片

### 第 6 步：日常营业

- **开店**：店里电脑/平板打开接单台网址并登录，保持前台（每 12 秒自动刷新，新订单有提示音）
- **顾客**：扫桌码 → 点餐 → 提交订单 → 页面显示金额 → 扫柜台收款码付款
- **店主**：接单台点「确认收款」→「开始制作」→「完成」，即完成一单

---

## 费用说明

| 项目 | 费用 |
|---|---|
| GitHub / Vercel / Supabase / 草料二维码 | 0 元 |
| 微信收款码（个人） | 免费（微信「收款小账本」申请） |
| 若日后有营业执照，换微信支付商户收款码 | 开通免费，按交易约 0.6% 收手续费，无需 300 元认证 |

## 注意点

- **金额以接单台核对为准**：网页端金额由顾客手机计算，接单台会重新显示订单明细，付款前核对一下即可
- **收款是人工核销**：免费方案不做自动扣款；顾客付款后你在接单台点「确认收款」
- **Supabase 免费项目闲置 7 天会暂停**：每天营业有读写就不会触发；万一暂停，登录控制台点 Resume 立即恢复
- **接单台 12 秒轮询**：新订单最迟 12 秒内出现并响铃；顾客端无需刷新
- **收款码合规**：个人收款码适合小额场景；长期经营建议有执照后开通微信支付商户收款码（更合规，可自动对账）
- **数据安全**：代码在你的 GitHub、数据在你的 Supabase，随时可迁移

## 常见问题

| 问题 | 处理 |
|---|---|
| 打开网页显示"还未配置完成" | `CONFIG` 里的网址或 anon key 没填对，重填后保存刷新 |
| 页面报"菜单加载失败" | 检查 SQL 是否已 Run；anon key 是否复制完整 |
| 接单台提示"登录失败" | 检查店主账号是否已在 Authentication → Users 创建，邮箱密码是否正确 |
| 菜品图片上传失败 | 确认 SQL 第 4 段（storage 策略）已执行；图片须为 jpg/png |
| 新订单没声音 | 电脑/平板音量打开；首次进入接单台后点一下页面任意位置（解锁音频） |
| 顾客看不到某道菜 | 该菜在菜单管理里是下架状态（开关为灰） |

## 安全说明

- 顾客（匿名）只能读菜单、提交订单，**无法修改**任何数据
- 店主操作需要邮箱密码登录（Supabase 托管的密码登录，token 存在本机）
- 不要公开分享店主账号密码；需要多人接单可在 Authentication 里多建几个账号
