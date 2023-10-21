multibranchPipelineJob('webapp') {
  branchSources {
    github {
      id('csye7125-webapp')
      scanCredentialsId('jenkins-karan')
      repoOwner('cyse7125-fall2023-group05')
      repository('webapp')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}

