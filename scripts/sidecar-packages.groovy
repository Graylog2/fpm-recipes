pipeline
{
   agent { label 'packages' }

   options
   {
      buildDiscarder logRotator(artifactDaysToKeepStr: '90', artifactNumToKeepStr: '100', daysToKeepStr: '90', numToKeepStr: '100')
      skipDefaultCheckout(true)
      timestamps()
      lock('os-package-build')
   }

   parameters
   {
     string(name: 'FEATURE_VERSION', description: 'Version of Sidecar to build. (1.0, 1.1, 1.2, etc)')
     gitParameter branchFilter: 'origin/(.*)', selectedValue: 'DEFAULT', name: 'BRANCH', type: 'PT_BRANCH', sortMode: 'DESCENDING_SMART', description: 'The branch of fpm-recipes that should be checked out (3.2, 3.3, master, etc).'
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

            sh "gl2-build-pkg-sidecar ${params.FEATURE_VERSION}"
         }

         post
         {
           cleanup
           {
             cleanWs()
           }
         }
      }
   }
}
