---
title: Speeding up Ionic app development with gulp
layout: post
date: 2015-02-10
---

# Javascript build tools and generators
Javascript tooling such as build systems and generators are everywhere nowadays and literally no one will start a fresh app or new website without them. It started with [Grunt](http://gruntjs.com/) and [Yeoman](http://yeoman.io/), but now there are many more such as [Gulp](https://github.com/gulpjs/gulp), [Broccoli](https://github.com/broccolijs/broccoli), [Slush](https://github.com/slushjs/slush), [Brunch](http://brunch.io/) and probably a dozen more. There is even a [book of modern frontend tooling](https://github.com/tooling/book-of-modern-frontend-tooling) currently written.

Of all these tools [Gulp](https://github.com/gulpjs/gulp) is definitely my favourite. It is all the hype lately, and I think the hype is well deserved, as it is very fast (because streams!) and very easy to use. I love it personally and I would not want to develop without it these days. We started using it for our Angular projects a while back and never looked back.
I noticed lots of Ionic folks using the [Yeoman Ionic Generator](https://github.com/diegonetto/generator-ionic) to kickstart their app development. While this generator does a lot of things really well I had to turn it down after a while, mostly because it was not flexible enough for our needs (This might be due to my limited ability to write Gruntfiles).
So I eventually ended up writing my own build job in Gulp, which worked pretty good for our needs (fast, simple, reliable, easy to adjust for team members).

# My Ionic gulp approach

Let's do a little breakdown of the build system I use for Ionic development. The code can be also [found on Github](https://github.com/tmaximini/ionic-gulp-seed).

My workflow is to develop most of the time in Chrome with [device emulation](https://developer.chrome.com/devtools/docs/device-mode), so this will be my default job. But I also need a quick way to run the app on a test device or inside an emulator.

| gulp command  | shortcut | what it does |
| ------------- | ------------- |
| `gulp` | --- | run local development server, start watchers, auto reload browser on change, targetfolder `/tmp` |
| `gulp --build` | `gulp -b`  | create a build from current `/app` folder, minify assets, targetfolder `/www` |
| `gulp --emulate <platform>` | `gulp -e <platform>` | run a build first, then `ionic emulate <platform>`. defaults to `ios` |
| `gulp --run <platform>` | `gulp -r <platform>` | run a build first, then `ionic run <platform>`. defaults to `ios` |

First, we need to determine what to do, and we do so by parsing the arguments passed to `gulp`.
In order to achieve this, we use the [yargs](https://github.com/chevex/yargs) module for parsing and setting default arguments:

{% highlight js %}
var args = require('yargs')
    .alias('e', 'emulate')
    .alias('b', 'build')
    .alias('r', 'run')
    .default('build', false)
    .default('port', 9000)
    .argv;


// emulate or run would also mean build
var build = args.build || args.emulate || args.run;
var emulate = args.emulate;
var run = args.run;
var port = args.port;
// if build we use 'www', otherwise '.tmp'
var targetDir = path.resolve(build ? 'www' : '.tmp');

// if we just use emualate or run without specifying platform, we assume iOS
// in this case the value returned from yargs would just be true
if (emulate === true) {
    emulate = 'ios';
}
if (run === true) {
    run = 'ios';
}

{% endhighlight %}

With the arguments parsed, gulp just runs through this sequence of tasks, where all tasks inside an array get done in parallel.
Note that the last 4 tasks are conditional, depending on in which mode we are running gulp.

{% highlight js %}
gulp.task('default', function(done) {
  runSequence(
    'clean',
    'iconfont',
    [
      'fonts',
      'templates',
      'styles',
      'images',
      'jsHint',
      'scripts',
      'vendor'
    ],
    'index',
    build ? 'noop' : 'watchers',
    build ? 'noop' : 'serve',
    emulate ? 'ionic:emulate' : 'noop',
    run ? 'ionic:run' : 'noop',
    done);
});

{% endhighlight %}

Let's go over a couple of tasks from our sequence in the next part to see how declarative gulp really is.

# Gulp building blocks

These are basic gulp tasks that get used in most build systems in more or less similar manner. Please note that `plugins` is an object holding different gulp modules. I am using [gulp-load-plugins](https://github.com/jackfranklin/gulp-load-plugins) for that.

### clean

This wipes out all contents from the targetfolder

{% highlight js %}
var del = require('del');
gulp.task('clean', function(done) {
  del([targetDir], done);
});
{% endhighlight %}


### styles
Precompiles sass files and does the automatic browser prefixing. Merges both compiled and Ionic's own CSS into a single `main.css` file. In build mode, also remove css comments and versionize the file.

{% highlight js %}
gulp.task('styles', function() {
  var options = build ?
                { style: 'compressed' } :
                { style: 'expanded' };

  var sassStream = plugins.rubySass('app/styles/main.scss', options)
      .pipe(plugins.autoprefixer('last 1 Chrome version', 'last 3 iOS versions', 'last 3 Android versions'))

  var cssStream = gulp
    .src('bower_components/ionic/css/ionic.min.css');

  return streamqueue({ objectMode: true }, cssStream, sassStream)
    .pipe(plugins.concat('main.css'))
    .pipe(plugins.if(build, plugins.stripCssComments()))
    .pipe(plugins.if(build, plugins.rev()))
    .pipe(gulp.dest(path.join(targetDir, 'styles')))
    .on('error', errorHandler);
});
{% endhighlight %}

### scripts

Prepares the [Angular templateCache](https://docs.angularjs.org/api/ng/service/$templateCache) from all templates in `app/templates`.
In build mode, also concats all javascript sources into a single versionized and minified `app.js` file.

{% highlight js %}
// build templatecache, copy scripts.
// if build: concat, minsafe, uglify and versionize
gulp.task('scripts', function() {
  var dest = path.join(targetDir, build ? '' : 'scripts');

  var minifyConfig = {
    collapseWhitespace: true,
    collapseBooleanAttributes: true,
    removeAttributeQuotes: true,
    removeComments: true
  };

  // prepare angular template cache from html templates
  // (remember to change appName var to desired module name)
  var templateStream = gulp
    .src('**/*.html', { cwd: 'app/templates'})
    .pipe(plugins.angularTemplatecache('templates.js', {
      root: 'templates/',
      module: appName,
      htmlmin: build && minifyConfig
    }));

  var scriptStream = gulp
    .src(['templates.js', 'app.js', '**/*.js'], { cwd: 'app/scripts' })

    .pipe(plugins.if(!build, plugins.changed(dest)));

  return streamqueue({ objectMode: true }, scriptStream, templateStream)
    .pipe(plugins.if(build, plugins.ngAnnotate()))
    .pipe(plugins.if(build, plugins.concat('app.js')))
    .pipe(plugins.if(build, plugins.uglify()))
    .pipe(plugins.if(build, plugins.rev()))

    .pipe(gulp.dest(dest))

    .on('error', errorHandler);
});
{% endhighlight %}


### inject

This is where happens most of the magic during development, because here all our development sources get automatically inserted into `index.html`. No need to manually add and remove `<script>` tags all the time. In the build process, it will inject the correct versionized file (Versionizing helps to avoid caching problems, not really an issue in Cordova apps but general good practice as all these techniques apply to browser development as well).

{% highlight js %}
// inject the files in index.html
gulp.task('index', function() {

  // build has a '-versionnumber' suffix
  var cssNaming = build ? 'styles/main-*' : 'styles/main*';

  var _inject = function(src, tag) {
    return plugins.inject(src, {
      starttag: '<!-- inject:' + tag + ':{{ext}} -->',
      read: false,
      addRootSlash: false
    });
  };

  // get all our javascript sources
  // in development mode, it's better to add each file seperately.
  // it makes debugging easier.
  var _getAllScriptSources = function() {
    var scriptStream = gulp.src(['scripts/app.js', 'scripts/**/*.js'], { cwd: targetDir });
    return streamqueue({ objectMode: true }, scriptStream);
  };

  return gulp.src('app/index.html')
    // inject css
    .pipe(_inject(gulp.src(cssNaming, { cwd: targetDir }), 'app-styles'))
    // inject vendor.js
    .pipe(_inject(gulp.src('vendor*.js', { cwd: targetDir }), 'vendor'))
    // inject app.js (build) or all js files indivually (dev)
    .pipe(plugins.if(build,
      _inject(gulp.src('app*.js', { cwd: targetDir }), 'app'),
      _inject(_getAllScriptSources(), 'app')
    ))

    .pipe(gulp.dest(targetDir))
    .on('error', errorHandler);
});
{% endhighlight %}

The entire gulpfile can be found [here](https://github.com/tmaximini/ionic-gulp-seed).

