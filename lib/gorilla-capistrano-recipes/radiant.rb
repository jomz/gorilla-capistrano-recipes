configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do  
  namespace :deploy do
    after "deploy:setup" do
        configs::copy_database_config
        public_files::create_shared_assets
        public_files::create_shared_galleries
        public_files::create_shared_page_attachments
    end
    after "deploy:update_code" do
        configs::link
        public_files::link_assets
        public_files::link_galleries
        public_files::link_page_attachments
    end
    after "deploy:cold", "deploy:radiant:bootstrap"
    after "deploy:migrate", "deploy:radiant:migrate:extensions"
    after "deploy:symlink" do
      run "mkdir -p #{latest_release}/cache"
    end
    
    desc "Overridden deploy:cold for Radiant."
    task :cold do
      update
      radiant::bootstrap
      #start
    end
  end

  namespace :radiant do
    desc "Radiant Bootstrap with empty template and default values."
    task :bootstrap do
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")

      run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} ADMIN_NAME=Administrator ADMIN_USERNAME=admin ADMIN_PASSWORD=radiant DATABASE_TEMPLATE=empty.yml OVERWRITE=true db:bootstrap"
    end

    namespace :migrate do
      desc "Runs migrations on extensions."
      task :extensions do
        rake = fetch(:rake, "rake")
        rails_env = fetch(:rails_env, "production")
        run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:migrate:extensions"
      end
    end

    namespace :content do
      desc "rsync the local public content to the current radiant deployment"
      task :push_local_public_to_current_public do
        set :deploy_to_path,  File.join(deploy_to,"current","public")
        system "rsync -avz -e ssh public/ #{user}@#{ehost}:#{deploy_to_path}"
      end

      desc "fetch server production_db to local production_db"
      task :fetch_server_prod_to_local_prod do
        set :current_radiant, File.join(deploy_to,"current")
        run "cd #{current_radiant}; rake "
      end

      desc "fetch assets"
      task :fetch_assets do
        set :deploy_to_path,  File.join(deploy_to,"current","public","assets")
        system "rsync -Lavz -e ssh #{user}@#{ehost}:#{deploy_to_path}/ public/assets "
      end

      desc "fetch gallery"
      task :fetch_galleries do
        set :deploy_to_path,  File.join(deploy_to,"current","public","galleries")
        system "rsync -Lavz -e ssh #{user}@#{ehost}:#{deploy_to_path}/ public/galleries "
      end
    end # eo content namespace

  end # eo radiant namespace

  namespace :public_files do
      desc "Create shared assets dir"
      task :create_shared_assets do
          run "mkdir -p #{shared_path}/public/assets"
      end

      desc "Create shared page_attachments dir"
      task :create_shared_page_attachments do
          run "mkdir -p #{shared_path}/public/page_attachments"
      end

      desc "Create shared galleries dir"
      task :create_shared_galleries do
          run "mkdir -p #{shared_path}/public/galleries"
      end

      desc "Link public/assets to shared/public/assets"
      task :link_assets do
          run "ln -nfs #{shared_path}/public/assets #{release_path}/public/assets"
      end

      desc "Link public/page_attachments to shared/public/page_attachments"
      task :link_page_attachments do
          run "ln -nfs #{shared_path}/public/page_attachments #{release_path}/public/page_attachments"
      end

      desc "Link public/galleries to shared/public/galleries"
      task :link_galleries do
          run "ln -nfs #{shared_path}/public/galleries #{release_path}/public/galleries"
      end
  end # eo public_files namespace
end