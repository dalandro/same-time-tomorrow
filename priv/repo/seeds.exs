alias SameTimeTomorrow.Repo
alias SameTimeTomorrow.Feeds.RssSource
alias SameTimeTomorrow.Vocab.{VocabList, VocabWord}

# RSS Sources

sources = [
  %{name: "新华社", url: "http://www.xinhuanet.com/rss/world.xml"},
  %{name: "人民日报", url: "http://www.people.com.cn/rss/politics.xml"},
  %{name: "BBC 中文", url: "https://feeds.bbci.co.uk/zhongwen/simp/rss.xml"},
  %{name: "VOA 中文", url: "https://www.voachinese.com/api/zmgqeoiutvmp"},
  %{name: "中国日报", url: "https://www.chinadaily.com.cn/rss/china_rss.xml"},
  %{name: "澎湃新闻", url: "https://www.thepaper.cn/rss_cn.jsp"},
  %{name: "财新网", url: "https://www.caixin.com/rss/all.xml"},
  %{name: "南方周末", url: "https://www.infzm.com/feed"}
]

Enum.each(sources, fn attrs ->
  %RssSource{}
  |> RssSource.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :url)
end)

IO.puts("Seeded #{length(sources)} RSS sources")

# HSK 3.0 Level 1 vocabulary (dev seed for testing article scoring)

hsk1_words = ~w(
  爱 爱好 八 爸爸 吧 白 白天 百 班 半 半年 半天 帮 帮忙 包 包子 杯 杯子 北 北边
  北京 本 本子 比 别 别的 别人 病 病人 不大 不对 不客气 不用 不 菜 茶 差 常 常常
  唱 唱歌 车 车票 车上 车站 吃 吃饭 出 出来 出去 穿 床 次 从 错 打 打车 打电话
  打开 打球 大 大学 大学生 到 得到 地 的 等 地点 地方 地上 地图 弟弟 第 点 电
  电话 电脑 电视 电视机 电影 电影院 东 东边 东西 动 动作 都 读 读书 对 对不起 多
  多少 饿 儿子 二 饭 饭店 房间 房子 放 放假 放学 飞 飞机 非常 分 风 干 干净
  干什么 高 高兴 告诉 哥哥 歌 个 给 跟 工人 工作 关 关上 贵 国 国家 国外 过
  还 还是 还有 孩子 汉语 汉字 好 好吃 好看 好听 好玩儿 号 喝 和 很 后 后边 后天
  花 话 坏 回 回答 回到 回家 回来 回去 会 火车 机场 机票 鸡蛋 几 记 记得 记住
  家 家里 家人 间 见 见面 教 叫 教学楼 姐姐 介绍 今年 今天 进 进来 进去 九 就
  觉得 开 开车 开会 开玩笑 看 看病 看到 看见 考 考试 渴 课 课本 课文 口 块 快
  来 来到 老 老人 老师 了 累 冷 里 里边 两 零 六 楼 楼上 楼下 路 路口 路上
  妈妈 马路 马上 吗 买 慢 忙 毛 没 没关系 没什么 没事儿 没有 妹妹 门 门口 门票
  们 米饭 面包 面条儿 名字 明白 明年 明天 拿 哪 哪里 哪儿 哪些 那 那边 那里 那儿
  那些 奶 奶奶 男 男孩儿 男朋友 男人 男生 南 南边 难 呢 能 你 你们 年 您 牛奶
  女 女儿 女孩儿 女朋友 女人 女生 旁边 跑 朋友 票 七 起 起床 起来 汽车 前 前边
  前天 钱 钱包 请 请假 请进 请问 请坐 球 去 去年 热 人 认识 认真 日 日期 肉
  三 山 商场 商店 上 上班 上边 上车 上次 上课 上网 上午 上学 少 谁 身上 身体
  什么 生病 生气 生日 十 时候 时间 事 试 是 是不是 手 手机 书 书包 书店 树 水
  水果 睡 睡觉 说 说话 四 送 岁 他 他们 她 她们 太 天 天气 听 听到 听见 听写
  同学 图书馆 外 外边 外国 外语 玩儿 晚 晚饭 晚上 网上 网友 忘 忘记 问 我 我们
  五 午饭 西 西边 洗 洗手间 喜欢 下 下班 下边 下车 下次 下课 下午 下雨 先 先生
  现在 想 小 小孩儿 小姐 小朋友 小时 小学 小学生 笑 写 谢谢 新 新年 星期 星期日
  星期天 行 休息 学 学生 学习 学校 学院 要 爷爷 也 页 一 衣服 医生 医院 一半
  一会儿 一块儿 一下儿 一样 一边 一点儿 一起 一些 用 有 有的 有名 有时候 有些 有用
  右 右边 雨 元 远 月 再 再见 在 在家 早 早饭 早上 怎么 站 找 找到 这 这边
  这里 这儿 这些 着 真 真的 正 正在 知道 知识 中 中国 中间 中文 中午 中学 中学生
  重 重要 住 准备 桌子 字 子 走 走路 最 最好 最后 昨天 左 左边 坐 坐下 做
)

existing = Repo.get_by(VocabList, name: "HSK 3.0 Level 1")

unless existing do
  {:ok, list} =
    %VocabList{}
    |> VocabList.changeset(%{name: "HSK 3.0 Level 1"})
    |> Repo.insert()

  now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

  Repo.insert_all(
    VocabWord,
    Enum.map(hsk1_words, &%{list_id: list.id, headword: &1, inserted_at: now, updated_at: now}),
    on_conflict: :nothing,
    conflict_target: [:list_id, :headword]
  )

  IO.puts("Seeded #{length(hsk1_words)} HSK 3.0 Level 1 words")
end

hsk2_words = ~w(
  啊 爱情 爱人 安静 安全 白色 班长 办 办法 办公室 半夜 帮助 饱 报名 报纸 北方 背
  比如 比如说 笔 笔记 笔记本 必须 边 变 变成 遍 表示 不错 不但 不够 不过 不太
  不要 不好意思 不久 不满 不如 不少 不同 不行 不一定 不一会儿 部分 才 菜单 参观
  参加 草 草地 层 查 差不多 长 常见 常用 场 超过 超市 车辆 称 成 成绩 成为
  重复 重新 出发 出国 出口 出门 出生 出现 出院 出租 出租车 船 吹 春节 春天 词
  词典 词语 从小 答应 打工 打算 打印 大部分 大大 大多数 大海 大家 大量 大门 大人
  大声 大小 大衣 大自然 带 带来 单位 但 但是 蛋 当 当时 倒 到处 道 道理 道路
  得 得出 的话 灯 等 等到 等于 低 地球 地铁 地铁站 点头 店 掉 东北 东方 东南
  冬天 懂 懂得 动物 动物园 读音 度 短 短信 段 队 队长 对 对话 对面 多 多久
  多么 多数 多云 而且 发 发现 饭馆 方便 方便面 方法 方面 方向 放下 放心 分 分开
  分数 分钟 份 封 服务 复习 该 改 改变 干杯 感到 感动 感觉 感谢 干活儿 刚 刚才
  刚刚 高级 高中 个子 更 公共汽车 公交车 公斤 公里 公路 公平 公司 公园 狗 够
  故事 故意 顾客 关机 关心 观点 广场 广告 国际 过来 过年 过去 海 海边 喊 好
  好处 好多 好久 好人 好事 好像 合适 河 黑 黑板 黑色 红 红色 后来 忽然 湖 护照
  花 花园 画 画家 画儿 坏处 坏人 欢迎 换 黄 黄色 回 回国 会 活动 或 或者 机会
  鸡 级 急 计划 计算机 加 加油 家 家庭 家长 假 假期 检查 见到 见过 件 健康 讲
  讲话 交 交给 交朋友 交通 角 角度 饺子 脚 叫作 教师 教室 教学 教育 接 接到
  接受 接下来 接着 街 节 节目 节日 结果 借 斤 今后 进入 进行 近 经常 经过 经理
  酒 酒店 就要 举 举手 举行 句 句子 卡 开机 开心 开学 看法 考生 靠 科 科学
  可爱 可能 可怕 可是 可以 克 刻 客人 课堂 空气 哭 快餐 快点儿 快乐 快要 筷子
  拉 来自 蓝 蓝色 篮球 老 老年 老朋友 老是 离 离开 礼物 里头 理想 例如 例子
  脸 练 练习 凉 凉快 两 亮 辆 零下 留 留下 留学生 流 流利 流行 路边 旅客 旅行
  旅游 绿 绿色 卖 满 满意 猫 米 面 面前 名 名称 名单 明星 目的 拿出 拿到 那
  那会儿 那么 那时候 那样 南方 难过 难看 难受 难题 难听 能够 年级 年轻 鸟 弄
  努力 爬 爬山 怕 排 排队 排球 碰 碰到 碰见 篇 便宜 片 漂亮 平 平安 平常 平等
  平时 瓶 瓶子 普通 普通话 其他 其中 骑 骑车 起飞 气 气温 千 千克 前年 墙 青年
  青少年 轻 清楚 晴 晴天 请客 请求 秋天 求 球场 球队 球鞋 取 取得 全 全部 全国
  全家 全年 全身 全体 然后 让 热情 人口 人们 人数 认为 日报 日子 如果 入口 商量
  商人 上周 少数 少年 身边 什么样 生 生词 生活 声音 省 十分 实际 实习 实现 实在
  食物 使用 市 市长 事情 收 收到 收入 手表 受到 舒服 熟 数 数字 水平 顺利 说明
  司机 送到 送给 算 虽然 随便 随时 所以 所有 它 它们 太太 太阳 态度 讨论 套
  特别 特点 疼 提 提出 提到 提高 题 体育 体育场 体育馆 天上 条 条件 听讲 听说
  停 停车 停车场 挺 挺好 通 通过 通知 同时 同事 同样 头 头发 图片 推 腿 外地
  外卖 完 完成 完全 晚安 晚报 晚餐 晚会 碗 万 网 网球 网站 往 为 为什么 位
  味道 喂 温度 闻 问路 问题 午餐 午睡 西北 西餐 西方 西南 西医 习惯 洗衣机 洗澡
  下 下雪 下周 夏天 相同 相信 响 想到 想法 想起 向 相机 像 小 小声 小时候 小说
  小心 小组 校园 校长 笑话 笑话儿 鞋 心里 心情 心中 新闻 信 信号 信息 信心
  信用卡 星星 行动 行人 行为 姓 姓名 休假 许多 选 学期 雪 颜色 眼 眼睛 养 样子
  要求 药 药店 药片 药水 也许 夜 夜里 一部分 一定 一共 一会儿 一路平安 一路顺风
  已经 以后 以前 以上 以外 以为 以下 椅子 一般 一点点 一生 一直 亿 意见 意思
  因为 阴 阴天 音节 音乐 音乐会 银行 银行卡 应该 英文 英语 影片 影响 永远 油
  游客 友好 有空儿 有人 有点儿 有意思 又 鱼 语言 原来 原因 院 院长 院子 愿意
  月份 月亮 越 越来越 云 运动 咱 咱们 脏 早餐 早晨 早就 怎么办 怎么样 怎样 占
  站 站住 长大 找出 照顾 照片 照相 这么 这时候 这样 真正 正常 正好 正确 正是
  直接 只 只能 只要 纸 中餐 中级 中年 中小学 中心 中医 重点 重视 周 周末 周年
  主人 主要 住房 住院 装 准确 自己 自行车 自由 字典 走过 走进 走开 租 组 组成
  组长 嘴 最近 作家 作文 作业 作用 座 座位 做到 做法 做饭
)

existing2 = Repo.get_by(VocabList, name: "HSK 3.0 Level 2")

unless existing2 do
  {:ok, list2} =
    %VocabList{}
    |> VocabList.changeset(%{name: "HSK 3.0 Level 2"})
    |> Repo.insert()

  now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

  Repo.insert_all(
    VocabWord,
    Enum.map(hsk2_words, &%{list_id: list2.id, headword: &1, inserted_at: now, updated_at: now}),
    on_conflict: :nothing,
    conflict_target: [:list_id, :headword]
  )

  IO.puts("Seeded #{length(hsk2_words)} HSK 3.0 Level 2 words")
end
