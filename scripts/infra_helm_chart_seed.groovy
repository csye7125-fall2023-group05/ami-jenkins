multibranchPipelineJob('infra-helm-chart') {
  branchSources {
    github {
      id('csye7125-infra-helm-chart')
      scanCredentialsId('jenkins-sydrawat')
      repoOwner('csye7125-fall2023-group05')
      repository('infra-helm-chart')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
