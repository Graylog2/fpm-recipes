pipeline
{
   agent { label 'packages' }

   options
   {
      buildDiscarder logRotator(artifactDaysToKeepStr: '30', artifactNumToKeepStr: '100', daysToKeepStr: '30', numToKeepStr: '100')
      skipDefaultCheckout(true)
      timestamps()
   }

   parameters
   {
     string(name: 'VERSION', description: 'Version of Graylog to build (3.2, 3.3, etc).')
     gitParameter branchFilter: 'origin/(.*)', defaultValue: '', name: 'BRANCH', type: 'PT_BRANCH', sortMode: 'DESCENDING_SMART', description: 'The branch of fpm-recipes that should be checked out (3.2, 3.3, master, etc).'
   }

   stages
   {
      stage('Build Packages')
      {
         steps
         {
            script
            {
              checkout([$class: 'GitSCM', branches: [[name: "refs/heads/${params.BRANCH}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github-app', url: 'https://github.com/Graylog2/fpm-recipes.git']]])
            }

            sh "gl2-build-pkg debian ${params.VERSION}"
            sh "gl2-build-pkg el ${params.VERSION}"
         }
      }
   }
}
