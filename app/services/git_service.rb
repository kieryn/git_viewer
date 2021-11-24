class GitService
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def log
    cmd = "git --git-dir #{Rails.root}/../#{path}/.git log --stat=10000"
    cache_file = "#{Rails.root}/cache/#{path}/git.log"
    FileUtils.mkdir_p("#{Rails.root}/cache/#{path}/")
    unless File.exist?(cache_file)
      stdout_str, _, exit_code = Open3.capture3(cmd)
      if exit_code.exitstatus == 0
        File.open(cache_file, 'w') { |file| file.write(stdout_str) }
      end
    end

    commits = []
    commit = false
    if File.exist?(cache_file)
      lines = File.read(cache_file).split("\n")
      lines.each do |line|
        if commit && line.start_with?('commit')
          commits.push(commit)
          commit = {}
        else
          commit = {} unless commit
          keys = %w(Merge Author Date)
          msg = true
          msg = false if line.start_with?('commit')
          if line.strip.end_with?('+') || line.strip.end_with?('-')
            commit['files'] ||= []
            fileinfo = line.split('|').map { |i| i.strip.split(' ') }
            if fileinfo.length > 1
              msg = false
              commit['files'].push({
                path: './' + fileinfo[0][0],
                change: fileinfo[1][0].to_i,
                ins: fileinfo[1][1].gsub('-', '').length,
                del: fileinfo[1][1].gsub('+', '').length
              })
            end
          end
          keys.each do |key|
            if line.start_with?(key + ':')
              commit[key.downcase] = line.gsub(key + ':', '').strip
              msg = false
            end
          end
          msg = false if line.include?('changed') && line.include?('insertions') && line.include?('deletions')
          if msg
            commit['msg'] = ("#{commit['msg']}\n#{line.strip}").strip

          end

        end
      end
    end

    return { cmd: cmd, commits: commits }
  end
end
