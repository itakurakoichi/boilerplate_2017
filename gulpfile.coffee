# TODO
#   minify: html, css, js
#   js: uglify, concat
#   gulp-load-plugins: modules named "gulp-" automatically required

fs = require 'fs'
gulp = require 'gulp'
webserver = require 'gulp-webserver'
extname = require 'gulp-extname'     # change file extension
notify = require 'gulp-notify'
plumber = require 'gulp-plumber'     # continue watching even if plugin error has occured
ejs = require('gulp-ejs');
sass = require 'gulp-sass'
postcss = require 'gulp-postcss'
autoprefixer = require 'autoprefixer'
# Check
htmlhint = require 'gulp-htmlhint'
csslint = require 'gulp-csslint'

# Function
## not stop procesing, notify error msg
plumberWithNotify = ->
	plumber errorHandler: notify.onError('<%= error.message %>')

# Setting Path
path =
	src:  'src/'
	dist: 'dist/'
	ejs:  'src/ejs/'
	scss: 'src/scss/'

# Tasks
json_path = "./config.json";
jsonData = JSON.parse(fs.readFileSync(json_path));

gulp.task 'html', ->
	gulp.src([
			path.ejs + '**/*.ejs'
			'!' + path.ejs + 'common/**/*.ejs'
		])
		.pipe(plumberWithNotify())
		.pipe(ejs(
			{ jsonData: jsonData },
			{ 'ext': '.html' }
		))
		.pipe(gulp.dest(path.dist + 'demo/'))

gulp.task 'css', ->
	processors = [
		autoprefixer({ browsers: ['last 5 versions'] })
		# easyImport({ glob: true })
		# mixins
		# simpleVars
		# nested
	];
	gulp.src(path.src + 'scss/**/*.scss')
		.pipe(plumberWithNotify())
		# .pipe(sass().on('error', sass.logError))
		.pipe(sass({
			# TODO: ここでminifyすると、linterでのエラー場所が分かりにくい、prod時に行なう
			# outputStyle: 'compressed'
			outputStyle: 'expanded'
		}))
		.pipe(postcss(processors))
		.pipe(gulp.dest(path.dist + 'css/'))

gulp.task 'htmlhint', ->
	gulp.src('demo/**/*.html', {cwd: path.dist})
		.pipe(htmlhint('.htmlhintrc'))
		.pipe(htmlhint.reporter())

gulp.task 'csslint', ->
	gulp.src(path.dist + 'css/**/*.css')
		.pipe(csslint('.csslintrc'))
		.pipe(csslint.formatter())   # Display errors
		#.pipe(csslint.formatter('fail'));   # Fail on error (or csslint.failFormatter())

gulp.task 'webserver', ->
	gulp.src(path.dist)
		.pipe(webserver({
			livereload: true
			port: 8000
		}))

gulp.task 'watch', ->
	gulp.watch(path.ejs + '/**/*.ejs', ['html', 'htmlhint'])
	gulp.watch(path.scss + '/**/*.scss', ['css', 'csslint'])
	# gulp.watch(path.src + '/js/*.js', ['js'])

# Development Task
gulp.task 'dev', [
	'webserver'
	'watch'
]

# Prod Task
# gulp.task 'prod', []
