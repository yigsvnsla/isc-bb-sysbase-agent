const config = {
  title: 'Sysbase Agent — Documentación Técnica',
  tagline: 'Migración Sybase ASE → PostgreSQL | Banco Bolivariano',
  url: 'http://localhost:3001',
  baseUrl: '/',
  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'banco-bolivariano',
  projectName: 'sysbase-agent-docs',

  presets: [
    [
      'classic',
      {
        docs: {
          path: 'docs',
          routeBasePath: '/',
          sidebarPath: './sidebars.js',
          sidebarCollapsible: true,
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      },
    ],
  ],

  plugins: ['./src/plugins/fixProgressPlugin.js'],

  themes: ['@docusaurus/theme-mermaid'],

  markdown: {
    mermaid: true,
  },

  themeConfig: {
    navbar: {
      title: 'Sysbase Agent Docs',
      logo: {
        alt: 'Sysbase Agent',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'mainSidebar',
          position: 'left',
          label: 'Documentación',
        },
        {
          href: 'https://github.com/yigsvnsla/isc-bb-sysbase-agent',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `Sysbase Agent — Banco Bolivariano`,
    },
    colorMode: {
      defaultMode: 'dark',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
    prism: {
      theme: require('prism-react-renderer').themes.dracula,
      additionalLanguages: ['java', 'sql', 'bash', 'yaml', 'json'],
    },
  },
};

module.exports = config;
