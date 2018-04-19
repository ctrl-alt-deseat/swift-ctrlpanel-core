const path = require('path')
const MinifyPlugin = require('babel-minify-webpack-plugin')
const { ConcatSource, ReplaceSource } = require('webpack-sources')

function ToSwiftPlugin (options) {
  this.options = options
}

ToSwiftPlugin.prototype.apply = function (compiler) {
  compiler.hooks.compilation.tap({ name: 'ToSwift' }, (compilation) => {
    compilation.hooks.optimizeChunkAssets.tapAsync({ name: 'ToSwift' }, (chunks, done) => {
      for (const chunk of chunks) {
        for (const fileName of chunk.files) {
          const source = compilation.assets[fileName].source()
          const escaped = new ReplaceSource(compilation.assets[fileName], fileName)

          for (let idx = source.lastIndexOf('\\'); idx !== -1; idx = source.lastIndexOf('\\', idx - 1)) {
            escaped.insert(idx, '\\')
          }

          compilation.assets[fileName] = new ConcatSource(`internal let ${this.options.variableName} = """\n`, escaped, '\n"""\n')
        }
      }

      done()
    })
  })
}

module.exports = {
  mode: 'production',
  entry: path.join(__dirname, 'index.js'),
  output: {
    path: path.join(__dirname, 'Sources'),
    filename: 'JSSource.swift'
  },
  optimization: {
    minimize: true
  },
  plugins: [
    new MinifyPlugin({}, {
      test: /\.swift$/,
      comments: false
    }),
    new ToSwiftPlugin({
      variableName: 'libraryCode'
    })
  ]
}
