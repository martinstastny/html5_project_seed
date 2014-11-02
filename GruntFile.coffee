module.exports = (grunt) ->
  "use strict"

  ###
    Settings object
    - please set your folders here, paths are relative to Gruntfile.js
  ###

  require('time-grunt')(grunt)

  settings =
    app: "app" # Development Folder name that holds all the files
    dist: "dist" # Production folder
    sassDir: "sass" # Folder name that hold sass files
    cssDir: "css" # Folder name that holds css files
    jsDir: "js" # Folder name that holds js files
    imgDir: "images"
    filesToCopy: "{html,txt,pdf,mp4,webm,mpeg,ogg,mp3,wav,eot,ttf,otf,woff,svg}"


  grunt.initConfig
    config: settings
    pkg: grunt.file.readJSON("package.json")

    # Watch task

    watch:
      sass:
        files: ["<%= config.app %>/**/*.{scss,sass}"]
        tasks: ["sass:dev"]
        options:
          nospawn: true

      coffee:
        files: ["<%= config.app %>/coffee/*.coffee"]
        tasks: ["coffee:dev"]


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
        flatten: true
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
        server:
          baseDir: "./app/"


    # Image compression

    imagemin:
      options:
        optimizationLevel: 3

      dist:
        files: [
          expand: true
          cwd: "<%= config.app %>"
          src: ["**/*.{png,jpg,jpeg,gif,bpm,svg}"]
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
          ]
        ]


    # Minify HTML

    htmlmin:
      dist:
        options:
          collapseBooleanAttributes: true
          collapseWhitespace: false
          removeComments: true
          removeAttributeQuotes: true
          removeCommentsFromCDATA: true
          removeEmptyAttributes: true
          removeOptionalTags: true
          removeRedundantAttributes: true
          useShortDoctype: true
        files: [
          expand: true
          cwd: "<%= config.app %>"
          src: "**/*.html"
          dest: "<%= config.dist %>"
        ]

    # Build minified and optimised scripts and replace their paths inside HTML

    useminPrepare:
      html: "<%= config.app %>/{,*/}*.html"
      options:
        dest: "<%= config.dist %>"


    usemin:
      html: ['<%= config.dist %>/{,*/}*.html']
      css: ['<%= config.dist %>/<%= config.cssDir %>/{,*/}*.css']
      options:
        assetsDirs: ["<%= config.dist %>"]


  # Loading tasks
  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-browser-sync"
  grunt.loadNpmTasks "grunt-contrib-imagemin"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-htmlmin"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-usemin"


  # Default grunt task
  grunt.registerTask "default", [
    "sass:dev"
    "browserSync"
    "watch"
    "watch:staticFiles"
  ]

  # Build task

  grunt.registerTask "build", [
    "clean:dist"
    "sass:dist"
    "useminPrepare"
    "concat:generated"
    "cssmin:generated"
    "uglify:generated"
    "copy:dist"
    "imagemin:dist"
    "usemin"
    "htmlmin:dist"
  ]
  return
