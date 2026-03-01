# frozen_string_literal: true

require 'cask'

class Object
  def false?
    nil?
  end
end

class String
  def false?
    empty? || strip == 'false'
  end
end

module Homebrew
  extend Utils::Output::Mixin
  module_function

  def print_command(*cmd)
    puts "[command]#{cmd.join(' ').gsub("\n", ' ')}"
  end

  def brew(*args)
    print_command ENV["HOMEBREW_BREW_FILE"], *args
    safe_system ENV["HOMEBREW_BREW_FILE"], *args
  end

  def git(*args)
    print_command ENV["HOMEBREW_GIT"], *args
    safe_system ENV["HOMEBREW_GIT"], *args
  end

  def read_brew(*args)
    print_command ENV["HOMEBREW_BREW_FILE"], *args
    output = `#{ENV["HOMEBREW_BREW_FILE"]} #{args.join(' ')}`.chomp
    puts "[status]#{$CHILD_STATUS.exitstatus}"
    puts "[output]#{output}"
    # TODO
    # brew livecheck returning 1 in CI despite returning 0 locally?
    # odie output if $CHILD_STATUS.exitstatus != 0
    output
  end

  # Get inputs
  message   	= ENV['HOMEBREW_BUMP_MESSAGE']  	#
  user_name 	= ENV['HOMEBREW_GIT_NAME']      	#
  user_email	= ENV['HOMEBREW_GIT_EMAIL']     	#
  org       	= ENV['HOMEBREW_BUMP_ORG']      	# 'orgName'
  no_fork   	= ENV['HOMEBREW_BUMP_NO_FORK']  	#
  tap_path  	= ENV['HOMEBREW_BUMP_TAP']      	# 'userName/tapName'
  cask_name 	= ENV['HOMEBREW_BUMP_CASK']     	# 'caskName'
  tag_path  	= ENV['HOMEBREW_BUMP_TAG']      	# 'refs/tags/v1.2.3'
  revision  	= ENV['HOMEBREW_BUMP_REVISION'] 	#
  livecheck 	= ENV['HOMEBREW_BUMP_LIVECHECK']	#
  dryrun    	= ENV['HOMEBREW_BUMP_DRYRUN']   	#

  # Check inputs
  if livecheck.false?
    odie "Need 'cask' input specified" if cask_name.blank?
    odie "Need 'tag' input specified"  if tag_path .blank?
  end

  # Avoid using the GitHub API whenever possible.
  # This helps users who use application tokens instead of personal access tokens.
  # Application tokens don't work with GitHub API's `/user` endpoit.
  if user_name.blank? && user_email.blank?
    # Get user details
    user      	= GitHub::API.open_rest "#{GitHub::API_URL}/user"
    user_id   	= user['id']
    user_login	= user['login']
    user_name 	= user['name'] || user['login'] if user_name.blank?
    user_email	= user['email'] || (
      # https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address
      user_created_at	= Date.parse user['created_at']
      plus_after_date	= Date.parse '2017-07-18'
      need_plus_email	= (user_created_at - plus_after_date).positive?
      user_email     	= "#{user_login}@users.noreply.github.com"
      user_email     	= "#{user_id}+#{user_email}" if need_plus_email
      user_email
    ) if user_email.blank?
  end

  # Tell git who you are
  git 'config', '--global', 'user.name' , user_name
  git 'config', '--global', 'user.email', user_email

  if tap_path.blank?
    brew 'tap', 'homebrew/core', '--force'
  else # Tap the requested tap if applicable
    brew 'tap', tap_path
  end

  # Append additional PR message
  message = if message.blank?
              ''
            else
              message + "\n\n"
            end
  message += '[`action-homebrew-bump-cask`](https://github.com/eugenesvk/action-homebrew-bump-cask)'

  # Do the livecheck stuff or not
  if livecheck.false?
    # Change cask name to full name: 'caskName' → 'userName/tapName/caskName'
    cask_full_name = tap_path + '/' + cask_name if !tap_path.blank? && !cask_name.blank?

    # Get info about cask
    myCask          	= Cask::CaskLoader::FromTapLoader.new(cask_full_name).load(config: nil)
    version_manifest	= myCask.version # v1.0.0
    url_old         	= myCask.url     # https://github.com/dev/app/releases/download/$version/app.zip
    is_git          	= (url_old.using === :git)

    # Prepare tag and url
    tag        	= tag_path.delete_prefix 'refs/tags/' # 'refs/tags/v1.2.3' → 'v1.2.3'
    version_tag	= Version.parse tag
    version    	= version_tag

    exit(0) if version_tag == version_manifest # exit if no version update required

    brew 'bump-cask-pr', # Finally bump the cask
      '--no-audit'            	                      	, # Don't run brew audit before opening the PR
      '--no-browse'           	                      	, # Print the pull request URL instead of opening in a browser
      '--no-style'            	                      	, # Don't run brew style --fix (avoids RuboCop infinite loops)
      "--message=#{message}"  	                      	, #
      *("--fork-org=#{org}"   	unless org    .blank?)	, # Use the specified GitHub organization for forking
      *("--no-fork"           	unless no_fork.false?)	, #
      *("--version=#{version}"	)                     	, # Specify the new version for the cask
      *('--dry-run'           	unless dryrun .false?)	, # Print what would be done rather than doing it
      cask_full_name
      # tag/revisions             	not supported in casks	  #
      # *('--sha256=#{sha256}'    	if     sha)           	, # best effort to determine the SHA-256 will be made if the value is not supplied by the user
      # *("--version=#{version}"  	unless is_git)        	, # Specify the new version for the cask
      # *("--url=#{url_new}"      	unless url_new.blank?)	, # Specify the URL for the new download
      # *("--url=#{url_new}"      	unless is_git)        	, # Specify the URL for the new download. Overrides #{version} templates, so skip it
      # *("--tag=#{tag}"          	if     is_git)        	, # part of bump-formula-pr, not brew-cask-pr
      # *("--revision=#{revision}"	if     is_git)        	, # part of bump-formula-pr, not brew-cask-pr
  else
    # Support multiple casks in input and change to full names if tap
    cask_full_name = cask_name
    unless cask_name.blank?
      cask_full_name	= cask_full_name.split(/[ ,\n]/).reject(&:blank?)
      cask_full_name	= cask_full_name.map { |f| tap_path + '/' + f } unless tap_path.blank?
    end

    # Get livecheck info
    json = read_brew \
      'livecheck',
      '--cask',
      # '--quiet', # don't suppress error output in logs
      '--newer-only',
      '--full-name',
      '--json',
      *("--tap=#{tap_path}" if !tap_path.blank? && cask_full_name.blank?),
      *(cask_full_name      unless                 cask_full_name.blank?)
    json = JSON.parse json

    # Define error
    err = nil

    # Loop over livecheck info
    json.each do |info|
      # Skip if there is no version field
      next unless info['version']

      # Get info about cask
      cask_name = info['cask']
      version = info['version']['latest']

      puts "Processing cask: #{cask_name}, version: #{version}" # Log processing details

      begin # Finally bump the cask
        brew 'bump-cask-pr',
          '--no-audit',
          '--no-browse',
          '--no-style',
          "--message=#{message}",
          "--version=#{version}",
          *("--fork-org=#{org}"	unless org   .blank?),
          *("--no-fork"        	unless no_fork.false?),
          *('--dry-run'        	unless dryrun.false?),
          cask_name
      rescue ErrorDuringExecution => e
        # Log the error details
        puts "Error during bump-cask-pr for #{cask_name}: #{e.message}"
        # Continue execution on error, but save the exception
        err = e
      end
    end

    # Die if error occurred
    odie err if err
  end
end
