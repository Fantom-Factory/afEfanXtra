using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afEfanExtra"
		summary = "A library for creating reusable Embedded Fantom (efan) components."
		version = Version([0,0,3])

		meta	= [ "org.name"		: "Alien-Factory",
					"org.uri"	 : "http://www.alienfactory.co.uk/",
					"vcs.uri"	 : "https://bitbucket.org/AlienFactory/afefanextra",
					"proj.name"	 : "EfanExtra",
					"license.name"	: "BSD 2-Clause License",
					"repo.private"	: "true"

					,"afIoc.module" : "afEfanExtra::EfanExtraModule"
				]


		index = [ "afIoc.module"	: "afEfanExtra::EfanExtraModule"
				]


		depends = ["sys 1.0", "concurrent 1.0", "build 1.0",
					"afIoc 1.4.6+", "afIocConfig 0+", "afEfan 1.3+", "afPlastic 1.0.5+"]
		srcDirs = [`test/unit-tests/`, `test/unit-tests/internal/`, `test/unit-tests/internal/utils/`, `test/unit-tests/components/`, `test/example/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`, `test/example/`, `test/unit-tests/components/`]

		docApi = true
		docSrc = true

		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
//		resDirs = resDirs.exclude { it.toStr.startsWith("test/") }
	}
}