multibranchPipelineJob('consumer-db') {
  branchSources {
    github {
      id('csye7125-consumer-db')
      scanCredentialsId('jenkins-sydrawat')
      repoOwner('csye7125-fall2023-group05')
      repository('consumer-db')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
