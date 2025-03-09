namespace :deploy do
  task :set_magento_permission do
    on roles(:all) do
      within release_path do
        execute "find #{release_path} -type d ! -perm 775 -exec chmod 775 {} +"
        execute "find #{release_path} -type f ! -perm 664 -exec chmod 664 {} +"
        execute "chmod +x #{release_path}/bin/magento"
      end
    end
  end

  task :composer_install do
    on roles(:all) do
      within release_path do
        if fetch(:deploy_mode) == "production"
          execute fetch(:php), "$(which composer)", "install --working-dir=#{release_path}", "--no-interaction", "--no-dev"
        else
          execute fetch(:php), "$(which composer)", "install --working-dir=#{release_path}", "--no-interaction"
        end
      end
    end
  end

  task :composer_dump_autoload do
    on roles(:all) do
      within release_path do
        if fetch(:deploy_mode) == "production"
          execute "composer dump-autoload --working-dir=#{release_path}", "-o --apcu"
        else
          execute "composer dump-autoload --working-dir=#{release_path}"
        end
      end
    end
  end

  task :set_deploy_mode do
    on roles(:all) do
      within release_path do
        if fetch(:deploy_mode) == "production"
          execute fetch(:php), 'bin/magento', 'deploy:mode:set', fetch(:deploy_mode), "--skip-compilation"
        else
          execute fetch(:php), 'bin/magento', 'deploy:mode:set', fetch(:deploy_mode)
        end
      end
    end
  end

  task :magento_maintenance_enable do
    on roles(:all) do
      within release_path do
        execute fetch(:php), 'bin/magento', 'maintenance:enable'
      end
    end
  end

  task :magento_setup_upgrade do
    on roles(:all) do
      within release_path do
        if fetch(:deploy_mode) == "production"
          execute fetch(:php), 'bin/magento', 'setup:upgrade', "--keep-generated"
        else
           execute fetch(:php), 'bin/magento', 'setup:upgrade'
        end
      end
    end
  end

  task :magento_compile do
    on roles(:all) do
      within release_path do
        execute fetch(:php), 'bin/magento', 'setup:di:compile'
      end
    end
  end

  task :npm_jobs do
    on roles(:all) do
      fetch(:hyva_tailwind_paths, []).each do |tailwind_path|
        within release_path + tailwind_path do
          execute :npm, :ci
          if fetch(:use_npm) == "true"
            execute :npm, :run, "build-prod"
          else
            execute :pnpm, :run, "build-prod"
          end
        end
      end
    end
  end

  task :magento_static_deploy do
    on roles(:all) do
      within release_path do
        execute fetch(:php), 'bin/magento', 'setup:static-content:deploy', '-f -j', fetch(:jobs)
      end
    end
  end

  task :magento_flush do
    on roles(:all) do
      within release_path do
        execute fetch(:php), 'bin/magento', 'cache:flush'
      end
    end
  end

  task :magento_maintenance_disable do
    on roles(:all) do
      within release_path do
        execute fetch(:php), 'bin/magento', 'maintenance:disable'
      end
    end
  end

  task :remove_old_cron_jobs do
    on roles(:web) do
      within release_path do
        cron_list = capture(:crontab, "-u #{fetch(:user)} -l || :")
        if cron_list.strip.empty?
          info "No old cron jobs found for user #{fetch(:user)}. Skipping removal."
        else
          execute :crontab, "-u #{fetch(:user)} -r"
          info "Old cron jobs removed for user #{fetch(:user)}."
        end
      end
    end
  end

  task :install_cron_jobs do
    on roles(:web) do
      within release_path do
        execute fetch(:php), "#{release_path}/bin/magento cron:install"
      end
    end
  end

  task :delete_failed_release do
    on roles(:all) do
      within release_path do
        execute "rm -rf #{release_path}"
      end
    end
  end

end

