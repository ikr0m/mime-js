var gulp = require('gulp'),
    concat = require('gulp-concat'),
    coffee = require('gulp-coffee'),
    uglify = require('gulp-uglify');

gulp.task('coffee-uglify', function () {
    var stream = gulp.src([
        "src/mime-js.coffee"
    ]);
    stream
        .pipe(coffee())
        .pipe(gulp.dest('./dist/'))
        .pipe(uglify())
        .pipe(concat({path: 'mime-js.min.js'}))
        .pipe(gulp.dest('./dist/'))
});

gulp.task('default', [
    'coffee-uglify'
]);