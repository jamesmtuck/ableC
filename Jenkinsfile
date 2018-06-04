#!groovy

library "github.com/melt-umn/jenkins-lib"

melt.setProperties(silverBase: true)

melt.trynode('ableC') {
  def ABLEC_BASE = env.WORKSPACE
  def ABLEC_GEN = "${ABLEC_BASE}/generated"
  def newenv = melt.getSilverEnv()

  stage ("Build") {

    checkout scm

    melt.clearGenerated()

    withEnv(newenv) {
      sh './build ${SVFLAGS} --warn-all --warn-error'
    }
  }

  stage ("Test") {
    dir("testing/expected-results") {
      withEnv(newenv) {
        sh "./runTests"
      }
    }
  }

  stage ("Tutorials") {
    dir("tutorials") {
      withEnv(newenv) {
        sh "./build-all"
      }
    }
  }

  stage ("Integration") {
    // All known, stable extensions to build downstream
    def extensions = [
      "ableC-skeleton", "ableC-lib-skeleton", "ableC-sample-projects",
      "ableC-algebraic-data-types",
      "ableC-checkBounds",
      "ableC-cilk",
      "ableC-closure",
      "ableC-refcount-closure",
      "ableC-condition-tables",
      "ableC-dimensionalAnalysis",
      "ableC-halide",
      "ableC-interval",
      "ableC-nonnull",
      "ableC-sqlite",
      "ableC-string",
      "ableC-templating",
      "ableC-vector",
      "ableC-watch",
      "ableC-nondeterministic-search", "ableC-nondeterministic-search-benchmarks"
    ]
    // Specific other jobs to build
    def specific_jobs = ["/melt-umn/ableP/master"]

    def tasks = [:]
    def newargs = [ABLEC_BASE: ABLEC_BASE, ABLEC_GEN: ABLEC_GEN] // SILVER_BASE inherited
    tasks << extensions.collectEntries { t ->
      [(t): { melt.buildProject("/melt-umn/${t}", newargs) }]
    }
    tasks << specific_jobs.collectEntries { t ->
      [(t): { melt.buildJob(t, newargs) }]
    }
    
    parallel tasks
  }

  /* If we've gotten all this way with a successful build, don't take up disk space */
  melt.clearGenerated()
}

