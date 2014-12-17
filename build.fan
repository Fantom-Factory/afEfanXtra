using build

class Build : BuildPod {

	new make() {
		podName = "afEfanXtra"
		summary = "A library for creating reusable Embedded Fantom (efan) components"
		version = Version("1.1.21")

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
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.4  - 1.0",
			"afConcurrent 1.0.8  - 1.0",
			"afPlastic    1.0.16 - 1.0",
			"afIoc        2.0.2  - 2.0", 
			"afIocConfig  1.0.16 - 1.0",
			"afIocEnv     1.0.14 - 1.0",
			
			// ---- Templating ------------------
			"afEfan       1.4.2  - 1.4"
		]

		srcDirs = [`test/unit-tests/`, `test/unit-tests/components/`, `test/example/`, `fan/`, `fan/public/`, `fan/public/advanced/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/lifecycle.png`, `test/example/`, `test/unit-tests/components/`]
	}
}