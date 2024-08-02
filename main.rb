# frozen_string_literal: true

require 'cask'
require 'utils/pypi'

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
    odie output if $CHILD_STATUS.exitstatus != 0
    output
  end

  # def patch_brew # temporary patch to fix an issue with a lack of mandatory 'is:pr' tags for GitHub APIs
    # script_path = File.expand_path File.dirname(__FILE__)
    # patch_fd   = 'patch'
    # patch_name = 'utils-github.patch'
    # patch_path = "#{script_path}/#{patch_fd}/#{patch_name}"
    # repo_root  = ENV["HOMEBREW_REPOSITORY"]
    # safe_system 'git','apply','--unsafe-paths',"--directory=#{repo_root}","#{patch_path}"
  # end
  # patch_brew

  # Get inputs
  message  	= ENV['HOMEBREW_BUMP_MESSAGE']  	#
  org      	= ENV['HOMEBREW_BUMP_ORG']      	# 'orgName'
  tap_path 	= ENV['HOMEBREW_BUMP_TAP']      	# 'userName/tapName'
  cask_name	= ENV['HOMEBREW_BUMP_CASK']     	# 'caskName'
  tag_path 	= ENV['HOMEBREW_BUMP_TAG']      	# 'refs/tags/v1.2.3'
  revision 	= ENV['HOMEBREW_BUMP_REVISION'] 	#
  force    	= ENV['HOMEBREW_BUMP_FORCE']    	#
  livecheck	= ENV['HOMEBREW_BUMP_LIVECHECK']	#
  dryrun   	= ENV['HOMEBREW_BUMP_DRYRUN']   	#

  # Check inputs
  if livecheck.false?
    odie "Need 'cask' input specified" if cask_name.blank?
    odie "Need 'tag' input specified"  if tag_path .blank?
  end

  # Get user details
  user      	= GitHub::API.open_rest "#{GitHub::API_URL}/user"
  user_id   	= user['id']
  user_login	= user['login']
  user_name 	= user['name'] || user['login']
  user_email	= user['email'] || (
    # https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address
    user_created_at	= Date.parse user['created_at']
    plus_after_date	= Date.parse '2017-07-18'
    need_plus_email	= (user_created_at - plus_after_date).positive?
    user_email     	= "#{user_login}@users.noreply.github.com"
    user_email     	= "#{user_id}+#{user_email}" if need_plus_email
    user_email
  )

  # Tell git who you are
  git 'config', '--global', 'user.name' , user_name
  git 'config', '--global', 'user.email', user_email

  # Tap the tap if desired
  brew 'tap', tap_path unless tap_path.blank?

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
    url_tag    	= url_old.to_s.gsub(version_manifest, version_tag)
    version    	= version_tag
    # url_new  	= url_tag # explicit urls override #{version} templates, so skip them

    exit(0) if version_tag == version_manifest # exit if no version update required

    # Check if cask is originating from PyPi
      # starts with PYTHONHOSTED_URL_PREFIX="https://files.pythonhosted.org/packages/"
    pypi_url = PyPI.update_pypi_url(url_old.to_s, version_tag)
    if pypi_url
      url_new = pypi_url       	# Substitute url
      brew 'install', 'pipgrip'	# Install pipgrip utility so resources from PyPi get updated too
    end

    brew 'bump-cask-pr', # Finally bump the cask
      '--no-audit'            	                      	, # Don't run brew audit before opening the PR
      '--no-browse'           	                      	, # Print the pull request URL instead of opening in a browser
      "--message=#{message}"  	                      	, #
      *("--fork-org=#{org}"   	unless org    .blank?)	, # Use the specified GitHub organization for forking
      *("--version=#{version}"	)                     	, # Specify the new version for the cask
      *("--url=#{url_new}"    	unless url_new.blank?)	, # Specify the URL for the new download
      *('--force'             	unless force  .false?)	, # Ignore duplicate open PRs
      *('--dry-run'           	unless dryrun .false?)	, # Print what would be done rather than doing it
      cask_full_name
      # tag/revisions             	not supported in casks	  #
      # *('--sha256=#{sha256}'    	if     sha)           	, # best effort to determine the SHA-256 will be made if the value is not supplied by the user
      # *("--version=#{version}"  	unless is_git)        	, # Specify the new version for the cask
      # *("--url=#{url_new}"      	unless is_git)        	, # Specify the URL for the new download
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
      '--quiet',
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

      begin # Finally bump the cask
        brew 'bump-cask-pr',
          '--no-audit',
          '--no-browse',
          "--message=#{message}",
          "--version=#{version}",
          *("--fork-org=#{org}"	unless org   .blank?),
          *('--force'          	unless force .false?),
          *('--dry-run'        	unless dryrun.false?),
          cask_name
      rescue ErrorDuringExecution => e
        # Continue execution on error, but save the exeception
        err = e
      end
    end

    # Die if error occured
    odie err if err
  end
end
