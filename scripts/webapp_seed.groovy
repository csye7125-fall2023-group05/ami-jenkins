multibranchPipelineJob('webapp') {
  branchSources {
    github {
      id('csye7125-webapp')
      scanCredentialsId('jenkins-sydrawat')
      repoOwner('csye7125-fall2023-group05')
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

