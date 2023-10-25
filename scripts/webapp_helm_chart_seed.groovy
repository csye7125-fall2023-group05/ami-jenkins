multibranchPipelineJob('webapp-helm-chart') {
  branchSources {
    github {
      id('csye7125-webapp-helm-chart')
      scanCredentialsId('jenkins-sydrawat')
      repoOwner('csye7125-fall2023-group05')
      repository('webapp-helm-chart')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
