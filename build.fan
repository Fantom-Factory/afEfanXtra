using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afEfanExtra"
		summary = "A library for creating reusable Embedded Fantom (efan) components."
		version = Version([0,0,1])

		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"vcs.uri"		: "https://bitbucket.org/Alien-Factory/afefanextra",
					"proj.name"		: "EfanExtra",
					"license.name"	: "BSD 2-Clause License",
					"repo.private"	: "true"
					// remove test res dirs!!!
					,"afIoc.module"	: "afEfanExtra::EfanExtraModule"
				]


		index	= [	"afIoc.module"	: "afEfanExtra::EfanExtraModule"
				]
 

		depends = ["sys 1.0", "concurrent 1.0",
					"afIoc 1.4+", "afEfan 1.0+", "afPlastic 1+"]
		srcDirs = [`test/unit-tests/`, `test/test-app/`, `test/example/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`, `test/test-app/`]

		docApi = true
		docSrc = true
 
		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
//		resDirs = resDirs.exclude { it.toStr.startsWith("test/") }
	}
}
