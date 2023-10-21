multibranchPipelineJob('webapp-db') {
  branchSources {
    github {
      id('csye7125-webapp-db')
      scanCredentialsId('jenkins-karan')
      repoOwner('cyse7125-fall2023-group05')
      repository('webapp-db')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
