class DataController < ActionController::Base
    def git_log
        path = params[:path]
        svc = GitService.new(path)
        render json: svc.log
    end
end
