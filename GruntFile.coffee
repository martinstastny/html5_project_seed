module.exports = (grunt) ->
  "use strict"

  require('time-grunt')(grunt)

  # Loading tasks for processes that you just currently need from [node_modules]
  require('jit-grunt')(grunt, {
    useminPrepare: 'grunt-usemin'
    concurrent: 'grunt-concurrent'
    filerev: 'grunt-filerev'
  })

  ###
     Settings object
     - please set your folders here, paths are relative to Gruntfile.js
  ###

  settings =
    app: "app" # Development Folder name that holds all the files
    dist: "dist" # Production folder
    sassDir: "sass" # Folder name that hold sass files
    cssDir: "css" # Folder name that holds css files
    jsDir: "js" # Folder name that holds js files
    imgDir: "images"
    coffeeDir: "coffee"
    filesToCopy: "{html,txt,pdf,mp4,webm,mpeg,ogg,mp3,wav,eot,ttf,otf,woff,svg,twig}"


  grunt.initConfig
    config: settings
    pkg: grunt.file.readJSON("package.json")


  # Watch task

    watch:
      sass:
        files: ["<%= config.app %>/<%= config.sassDir %>/*.{scss,sass}"]
        tasks: ["newer:sass:dev"]
        options:
          nospawn: true

      coffee:
        files: ["<%= config.app %>/<%= config.coffeeDir %>/*.coffee"]
        tasks: ["newer:coffee:dev"]


  # SASS compilation

    sass:
      dev:
        options:
          outputStyle: "expanded"
          lineNumbers: true
          sourceMap: true

        files: [
          expand: true
          cwd: "<%= config.app %>/<%= config.sassDir %>"
          src: [
            "*.sass"
            "*.scss"
          ]
          dest: "<%= config.app %>/<%= config.cssDir %>"
          ext: ".css"
        ]

      dist:
        options:
          outputStyle: "compressed"
          sourceMap: false

        files: [
          expand: true
          cwd: "<%= config.app %>/<%= config.sassDir %>"
          src: [
            "*.sass"
            "*.scss"
          ]
          dest: "<%= config.dist %>/<%= config.cssDir %>"
          ext: ".min.css"
        ]


  # CoffeeScript task

    coffee:
      options:
        sourceMap: true
        sourceMapDir: "<%= config.app %>/js"

      dev:
        expand: true
        cwd: "<%= config.app %>/coffee"
        src: ["*.coffee"]
        dest: "<%= config.app %>/<%= config.jsDir %>"
        ext: ".js"


  # Live reloading browser on desktop and mobile devices

    browserSync:
      bsFiles:
        src: [
          "<%= config.app %>/**/*.html"
          "<%= config.app %>/<%= config.cssDir %>/*.css"
          "<%= config.app %>/static/<%= config.jsDir %>/{,*/}*.js"
        ]

      options:
        watchTask: true
        proxy: 'reiss.dev' # Set to your hostname e.g. 'reiss.dev'

        # Uncomment these if you want BrowserSync to run server for you
        #server:
        #  baseDir: "./app/"


  # Image compression

    imagemin:
      options:
        optimizationLevel: 3

      dist:
        files: [
          expand: true
          cwd: "<%= config.app %>"
          src: ["**/*.{png,jpg,jpeg,gif,bpm,svg}", '!**/bower_components/**/*']
          dest: "<%= config.dist %>"
        ]


  # Uglify and compress js, used by useminPrepare

    uglify:
      options:
        compress: true
        mangle: true


  # Delete files and folders

    clean:
      dist:
        src: ["<%= config.dist %>/*"]


  # Copy files

    copy:
      dist:
        files: [
          expand: true
          cwd: '<%= config.app %>'
          dest: '<%= config.dist %>'
          src: [
            '.htaccess'
            '**/*.<%= config.filesToCopy %>'
            '!**/bower_components/**/*' # Ignore bower_components folder and do not copy to disribution
          ]
        ]


  # Minify HTML

    htmlmin:
      dist:
        options:
          collapseBooleanAttributes: true
          collapseWhitespace: false
          removeComments: false
          removeAttributeQuotes: false
          removeCommentsFromCDATA: true
          removeEmptyAttributes: true
          removeOptionalTags: true
          removeRedundantAttributes: true
          useShortDoctype: true
        files: [
          expand: true
          cwd: "<%= config.app %>"
          src: ['**/*.html', '!**/bower_components/**/*']
          dest: "<%= config.dist %>"
        ]


  # Build minified and optimised scripts and replace their paths inside HTML

    useminPrepare:
      html: "<%= config.app %>/index.html"
      options:
        dest: "<%= config.dist %>"


    usemin:
      html: ['<%= config.dist %>/*.{twig,html}']
      css: ['<%= config.dist %>/<%= config.cssDir %>/{,*/}*.css']
      options:
        assetsDirs: ["<%= config.dist %>"]


  # File versioning - renaming files to unique names - prevent caching

    filerev:
      options:
        algorithm: 'md5'
        length: 8

      files:
        src: [
          '<%= config.dist %>/css/**/*.css'
          '<%= config.dist %>/js/**/*.js'
        ]



  # Default grunt task
  grunt.registerTask "default", [
    "sass:dev"
    "browserSync"
    "watch"
  ]


  # Build task
  grunt.registerTask "build", [
    "clean:dist"
    "sass:dist"
    "coffee:dev"
    "useminPrepare"
    "concat:generated"
    "cssmin:generated"
    "uglify:generated"
    "copy:dist"
    "imagemin:dist"
    "filerev"
    "htmlmin:dist"
    "usemin"
  ]


  return