module BangBang
  class Service
    attr_reader :app_config, :root_dir
    attr_accessor :url_prefix

    def initialize(app_config, dir)
      @app_config = app_config
      @root_dir = dir
    end

    def init
      append_load_paths
      eval_init_rb
      init_controllers
      autoload_models
      yield(self) if block_given?
      self
    end

    def append_load_paths
      $LOAD_PATH << lib_dir if File.directory?(lib_dir)
    end

    def get_presenter_file_path(url)
      stripped_url_prefix = strip_url_prefix(url)
      file_path = File.join(presenters_dir, "#{stripped_url_prefix}.rb")
      File.file?(file_path) ? file_path : nil
    end

    def get_stylesheet_file_path(url)
      stripped_url_prefix = strip_url_prefix(url)
      file_path = File.join(app_dir, stripped_url_prefix.gsub(/\.css$/, ".sass"))
      File.file?(file_path) ? file_path : nil
    end

    def get_static_file_path(url)
      stripped_url_prefix = strip_url_prefix(url)
      static_file_dirs.each do |dir|
        file_path = File.join(dir, stripped_url_prefix)
        return file_path if File.file?(file_path)
      end
      nil
    end

    def get_spec_urls(url)
      specs_url_prefix = File.join(url_prefix.to_s, "specs")
      stripped_url_prefix = strip_url_prefix(url, specs_url_prefix)
      path = File.join(spec_javascripts_dir, stripped_url_prefix.to_s)
      get_specs_urls_from_path(path)
    end

    def get_specs_urls_from_path(path=spec_javascripts_dir)
      (Dir["#{path}/**/*_spec.js"] + Dir["#{path}.js"]).flatten.compact.map do |file|
        file.gsub(spec_javascripts_dir, File.join(url_prefix.to_s, "specs")).gsub("//", "/")
      end
    end

    def get_spec_file_path(url)
      specs_url_prefix = File.join(url_prefix.to_s, "specs")
      stripped_url_prefix = strip_url_prefix(url, specs_url_prefix)
      file_path = File.join(spec_javascripts_dir, stripped_url_prefix)
      file_path if File.file?(file_path)
    end

    def app_dir
      File.join(root_dir, "app")
    end

    def presenters_dir
      File.join(app_dir, "presenters")
    end

    def templates_dir
      File.join(app_dir, "templates")
    end

    def stylesheets_dir
      File.join(app_dir, "stylesheets")
    end

    def templates_hash
      Dir["#{templates_dir}/**/*.*"].inject({}) do |memo, path|
        memo[path.gsub(templates_dir, url_prefix.to_s)] = File.read(path)
        memo
      end
    end

    def javascript_urls(params={})
      return [] unless File.directory?(public_javascripts_dir)
      glob = params[:glob] || "**/*.js"
      cache_buster = params.has_key?(:cache_bust) ? params[:cache_bust] : true
      Dir["#{public_javascripts_dir}/#{glob}"].sort_by(&BangBang::Plugins::DirectoryFirstSort.directory_first_sort).map do |file|
        asset_url(file, file.gsub(public_javascripts_dir, "#{url_prefix}/javascripts"), cache_buster)
      end
    end

    def stylesheet_urls(params = {})
      return [] unless File.directory?(stylesheets_dir)
      glob = params[:glob] || "**/[^_]*.css"
      cache_buster = params.has_key?(:cache_bust) ? params[:cache_bust] : true
      sass_glob = glob.gsub(/\.css$/, ".sass")
      Dir["#{stylesheets_dir}/#{sass_glob}"].sort_by(&BangBang::Plugins::DirectoryFirstSort.directory_first_sort).map do |file|
        asset_url(file, file.gsub(stylesheets_dir, "#{url_prefix}/stylesheets").gsub(/\.sass$/, ".css"), cache_buster)
      end
    end

    def spec_javascripts_dir
      File.join(root_dir, "spec/javascripts")
    end

    def init_controllers
      controllers_dir = File.join(root_dir, "app/controllers")
      if File.directory?(controllers_dir)
        module_files = Dir["#{controllers_dir}/**/*.module.rb"]
        module_files.each do |file|
          require file
        end

        directory_first_sort = BangBang::Plugins::DirectoryFirstSort.directory_first_sort
        (Dir["#{controllers_dir}/**/*.rb"] - module_files).sort_by(&directory_first_sort).each do |file|
          require file
        end
      end
    end

    def autoload_models
      models_dir = File.join(root_dir, "app/models")
      if File.directory?(models_dir)
        directory_first_sort = BangBang::Plugins::DirectoryFirstSort.directory_first_sort
        Dir["#{models_dir}/**/*.rb"].sort_by(&directory_first_sort).each do |file|
          const_name_parts = file.
            gsub(models_dir, "").
            gsub("-", "_").
            gsub(/\.rb/, "").
            camelize.
            split("::").
            select {|part| part.present?}
          parent_const = const_name_parts[0..-2].join("::").constantize
          parent_const.autoload const_name_parts[-1].to_sym, file
        end
      end
    end

    def public_dir
      File.join(root_dir, "public")
    end

    protected
    def lib_dir
      File.join(root_dir, "lib")
    end

    def asset_url(file, url_path, cache_buster)
      if cache_buster
        "#{url_path}?_cb=#{File.mtime(file).to_i}"
      else
        url_path
      end
    end

    def static_file_dirs
      [public_dir, templates_dir]
    end

    def public_javascripts_dir
      File.join(public_dir, "javascripts")
    end

    def strip_url_prefix(url_path, prefix=url_prefix)
      url_path.gsub(Regexp.new("^#{prefix}"), "")
    end

    def eval_init_rb
      init_rb_path = "#{root_dir}/init.rb"
      if File.exists?(init_rb_path)
        instance_eval(File.read(init_rb_path), init_rb_path, 1)
      end
    end
  end
end
