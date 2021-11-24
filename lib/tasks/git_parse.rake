namespace :git do
    desc "Update states table"
    task log: :environment do
      svc = GitService.new("<path_to_repo>")
      puts svc.log.to_json
    end
end