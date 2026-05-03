alias SameTimeTomorrow.Repo
alias SameTimeTomorrow.Feeds.RssSource

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
