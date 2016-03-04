require 'fileutils'

module Pod
  class Command
    class Setup < Command
      self.summary = 'Setup the hCODE development kit environment'

      self.description = <<-DESC
        Creates a directory at `~/.hcode/repos` which will hold your spec-repos.
        This is where it will create a clone of the public `master` spec-repo from:

            https://github.com/hCODE-FPGA/Specs

        If the clone already exists, it will ensure that it is up-to-date.
      DESC

      def self.options
        [
          ['--no-shallow', 'Clone full history so push will work'],
        ].concat(super)
      end

      extend Executable
      executable :git

      def initialize(argv)
        @shallow = argv.flag?('shallow', true)
        super
      end

      def run
        UI.section 'Setting up hCODE master repo' do
          if master_repo_dir.exist?
            set_master_repo_url
            set_master_repo_branch
            update_master_repo
          else
            add_master_repo
          end
        end

        UI.puts 'Setup completed'.green
      end

      #--------------------------------------#

      # @!group Setup steps

      # Sets the url of the master repo according to whether it is push.
      #
      # @return [void]
      #
      def set_master_repo_url
        Dir.chdir(master_repo_dir) do
          git('remote', 'set-url', 'origin', url)
        end
      end

      # Adds the master repo from the remote.
      #
      # @return [void]
      #
      def add_master_repo
        cmd = ['master', url, 'master']
        cmd << '--shallow' if @shallow
        Repo::Add.parse(cmd).run
      end

      # Updates the master repo against the remote.
      #
      # @return [void]
      #
      def update_master_repo
        SourcesManager.update('master', true)
      end

      # Sets the repo to the master branch.
      #
      # @note   This is not needed anymore as it was used for CocoaPods 0.6
      #         release candidates.
      #
      # @return [void]
      #
      def set_master_repo_branch
        Dir.chdir(master_repo_dir) do
          git %w(checkout master)
        end
      end

      #--------------------------------------#

      # @!group Private helpers

      # @return [String] the url to use according to whether push mode should
      #         be enabled.
      #
      def url
        self.class.read_only_url
      end

      # @return [String] the read only url of the master repo.
      #
      def self.read_only_url
        'https://github.com/hCODE-FPGA/Specs.git'
      end

      # @return [Pathname] the directory of the master repo.
      #
      def master_repo_dir
        SourcesManager.master_repo_dir
      end
    end
  end
end
