using build

class Build : BuildPod {

	new make() {
		podName = "afEfanXtra"
		summary = "A library for creating reusable Embedded Fantom (efan) components"
		version = Version("1.1.5")

		meta = [
			"proj.name"		: "efanXtra",
			"afIoc.module"	: "afEfanXtra::EfanXtraModule",
			"tags"			: "templating",
			"repo.private"	: "true"
		]

		index = [
			"afIoc.module"	: "afEfanXtra::EfanXtraModule" 
		]

		depends = [	
			"sys 1.0", 
			"concurrent 1.0",
			"fandoc 1.0",
			
			"afBeanUtils 1.0.0+",
			"afConcurrent 1.0.6+",
			"afPlastic 1.0.14+",
			"afIoc 1.6.4+", 
			"afIocConfig 1.0.8+",			
			"afEfan 1.4.0.1+"
		]

		srcDirs = [`test/unit-tests/`, `test/unit-tests/internal/`, `test/unit-tests/internal/utils/`, `test/unit-tests/components/`, `test/example/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/lifecycle.png`, `test/example/`, `test/unit-tests/components/`]

		docApi = true
		docSrc = true
	}
}