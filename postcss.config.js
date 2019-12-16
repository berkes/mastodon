module.exports = ({ env }) => ({
  plugins: {
    autoprefixer: {},
    'postcss-object-fit-images': {},
    cssnano: (env === 'production' || env === 'staging') ? {} : false,
  },
});
