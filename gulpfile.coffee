path = require('path')
gulp = require('gulp')
gutil = require 'gulp-util'

runSequence = require('run-sequence')
browserify = require 'browserify'
filter = require 'gulp-filter'

source = require 'vinyl-source-stream'
exorcist = require 'exorcist'

clean = require('gulp-rimraf')
coffee = require ('gulp-coffee')
mocha = require('gulp-mocha')
mochaPhantomJS = require('gulp-mocha-phantomjs')
livereload = require('gulp-livereload')

browserSync = require('browser-sync')
reload = browserSync.reload

minimist = require('minimist')
argv = minimist(process.argv.slice(2))

do ->
  if argv.debug then argv.env = 'debug'
  if argv.dist then argv.env = 'dist'
  if argv.t then argv.test = true

xtask = ->

task = gulp.task.bind(gulp)
watch = gulp.watch.bind(gulp)
src = gulp.src.bind(gulp)
dest = gulp.dest.bind(gulp)

srcStream = src('').constructor
srcStream::to = (dst) -> @pipe(dest(dst))
srcStream::pipelog = (obj, log=gutil.log) -> @pipe(obj).on('error', log)

#task 'wait', -> gulp.src('src/server/app.coffee').pipe(wait(300))

task 'clean', -> src( ['dist'], {read:false}).pipe(clean())

task 'copy', -> src(['src/**/*.js', 'src/**/*.json', 'src/**/*.css', 'src/**/*.html'], {cache:'copy'}).to( 'dist')

task 'coffee', -> src('src/**/*.coffee').pipelog(coffee({bare: true})).pipe(dest('dist'))

onErrorContinue = (err) -> console.log(err.stack); @emit 'end'
task 'mocha', ->  src('app/test/mocha-server/**/test*.js').pipe(mocha({reporter: 'spec'})).on("error", onErrorContinue)
#task 'test', (callback) -> runSequence('make', 'mocha', callback)

# http://pem-musing.blogspot.com/2014/04/famous-with-gulpjs-and-browerify-in.html
task 'brow', ->
  lst = [
#    {src:'./src/lib/', file: 'dcom.js', dest:'dist/lib/'},
#    {src:'./src/demo/event/', file: 'index.js', dest:'dist/demo/event/'}
#    {src:'./src/demo/sum/', file: 'index.js', dest:'dist/demo/sum/'}
#    {src:'./src/demo/todomvc/', file: 'index.js', dest:'dist/demo/todomvc/'}
    {src:'./src/test/', file: 'mocha-phantomjs-index.js', dest:'dist/test/'}
  ]
  for item in lst
    options =
      entries: [item.src+item.file]
      extensions: ['.coffee', '.js']
    #if argv.env!='production' then options.debug = false
    p = browserify(options)
    .transform 'coffeeify'
    .bundle()
    #if argv.env!='production' then p = p.pipe(exorcist(item.dest+item.file+'.map'))
    p = p.pipe(source(item.file)).pipe(dest item.dest)
    if item.src=='./src/test/'
      p.pipe(filter('**/*.js')).pipe(browserSync.reload({stream:true}))

task 'sync', -> browserSync({
  server: {
    baseDir: "./"
    files: ["bower_components/**/*.css", "bower_components/**/*.js", "dist/test/**/*.js"]
    index: "dist/test/mocha-phantomjs-runner.html"
    startPath: "dist/test/mocha-phantomjs-runner.html"
    watchOptions: {
      debounceDelay: 300
    }
  }
})

task 'watch',  ->
  #server = livereload()
  gulp.watch ['src/**/*.css', 'src/**/*.html', 'src/**/*json'], ['copy']
  gulp.watch 'src/server/**/*.coffee', ['coffee']
  gulp.watch 'src/modules/**/*.coffee', ['coffee']
  gulp.watch 'src/modules/**/*.coffee', ['brow']
  gulp.watch 'src/test/mocha-phantomjs/**/*.coffee', ['brow']
  gulp.watch 'src/test/mocha-phantomjs-index.js', ['brow']
  #gulp.watch(["dist/test/index.js", "dist/test/mocha-runner.html"], [browserSync.reload])
  #gulp.watch("dist/test/mocha-phantomjs-index.js", [browserSync.reload])


xtask 'watch',  ->
  gulp.watch ['src/**/*.css', 'src/**/*.html', 'src/**/*.js','src/**/*json'], ['copy']
  gulp.watch 'src/**/*.coffee', ['coffee']

task 'build', (callback) -> runSequence 'clean', ['copy', 'brow'],  'sync', callback #coffee

task 'bw', (callback) -> runSequence 'build', ['watch'], callback

task 'b', ['build']
task 'w', ['watch']

task 'default', ['b']

