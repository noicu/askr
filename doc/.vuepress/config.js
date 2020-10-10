module.exports = {
  title: 'Askr',
  lang: 'zh-CN',
  description: 'tovi',
  base: '/',
  themeConfig: {
    nav: [
      { text: '模板', link: '/doc/testtemplate' }
    ],
    sidebar: {
      '/': [
        // "/",
        "/doc/supply",
        "/doc/node",
        "/doc/motion",
        "/doc/curve",
        "/doc/testtemplate",
      ]
    },
    sidebarDepth: 2
  },
  markdown: {
    lineNumbers: true
  },
}