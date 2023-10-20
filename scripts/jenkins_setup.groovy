organizationFolder("GitHub organization") {
  displayName("GitHub organization")
  description("GitHub organization")
  organizations {
    github {
      repoOwner("csye7125-fall2023-group05")
      scanCredentialsId("github-organization-credentials")
      apiUri("https://api.github.com")
      

      configure { node ->
        def traits = node / navigators / 'org.jenkinsci.plugins.github_branch_source.GitHubSCMNavigator' / traits

        // Discover branches
        // https://javadoc.jenkins.io/plugin/github-branch-source/org/jenkinsci/plugins/github_branch_source/BranchDiscoveryTrait.html
        traits << 'org.jenkinsci.plugins.github__branch__source.BranchDiscoveryTrait' {
          strategyId('1')
          // Values
          // 1: Exclude branches that are also filed as PRs
          // 2: Only branches that are also filed as PRs
          // 3: All branches
          // 
        }

        // Discover pull requests from origin
        // https://javadoc.jenkins.io/plugin/github-branch-source/org/jenkinsci/plugins/github_branch_source/OriginPullRequestDiscoveryTrait.html
        traits << 'org.jenkinsci.plugins.github_branch_source.OriginPullRequestDiscoveryTrait' {
          strategyId('2')
          // Values
          // 1. Merging the pull request with the current target branch revision
          // 2. The current pull request revision
          // 3. Both the current pull request revision and the pull request merged with the current target branch revision
        }

        // Discover pull requests from forks
        // https://javadoc.jenkins.io/plugin/github-branch-source/org/jenkinsci/plugins/github_branch_source/ForkPullRequestDiscoveryTrait.html
        traits << 'org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait' {
          // Strategy
          strategyId('2')
          // Values
          // 1. Merging the pull request with the current target branch revision
          // 2. The current pull request revision
          // 3. Both the current pull request revision and the pull request merged with the current target branch revision

          // Trust
          trustId('4')
          // Values
          // 1. No trust
          // 2. Collaborators
          // 3. Everyone
          // 4. From users with Admin or Write permission
        }
      } 
    }
    // Project Recognizers
    projectFactories {
      workflowMultiBranchProjectFactory {
        scriptPath 'Jenkinsfile'
      }
    }

    // TODO: Property Strategy

    // Orphaned Item Strategy
    orphanedItemStrategy {
      discardOldItems {
        daysToKeep(-1)
        numToKeep(-1)
      }
    }

    // Scan Organization Folder Triggers: 1 day
    configure { node -> 
      node / triggers / 'com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger' {
        spec('H H * * *')
        interval(86400000)
      }
    }
  }
}