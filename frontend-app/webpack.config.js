const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');

module.exports = {
  entry: './src/index.jsx',

  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    publicPath: '/',         // IMPORTANT for SPA routing
    clean: true
  },

  resolve: {
    extensions: ['.js', '.jsx'],
  },

  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
use: {
          loader: 'babel-loader',
          options: {
            presets: [
              '@babel/preset-env',
              '@babel/preset-react'
            ]
          }
        }      },
      {
        test: /\.css$/,
        use: ['style-loader','css-loader']
      },
    ],
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html',   // Source index.html
      filename: 'index.html'             // Output to dist/
    }),
    new webpack.DefinePlugin({
      'process.env.API_BASE_URL': JSON.stringify('/api')
    })
  ],

  devServer: {
    historyApiFallback: true,
  }
  }
