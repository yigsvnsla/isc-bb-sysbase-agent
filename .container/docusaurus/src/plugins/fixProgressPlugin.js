module.exports = function (context, options) {
  return {
    name: 'fix-progress-plugin',
    configureWebpack(config, isServer, utils) {
      config.plugins = config.plugins.filter((plugin) => {
        const name = plugin?.constructor?.name || '';
        return name !== 'ProgressPlugin'
          && name !== 'WebpackBarProgressPlugin'
          && name !== 'CustomRspackProgressPlugin';
      });
      return {};
    },
  };
};
