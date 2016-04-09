using build

class Build : BuildPod {

	new make() {
		podName = "afEfanXtra"
		summary = "A library for creating reusable Embedded Fantom (efan) components"
		version = Version("1.2.1")

		meta = [
			"proj.name"		: "efanXtra",
			"afIoc.module"	: "afEfanXtra::EfanXtraModule",
			"repo.tags"		: "templating",
			"repo.public"	: "false"
		]

		index = [
			"afIoc.module"	: "afEfanXtra::EfanXtraModule" 
		]

		depends = [	
			"sys          1.0.68 - 1.0", 
			"concurrent   1.0.68 - 1.0",
			"fandoc       1.0.68 - 1.0",
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.12 - 1.0",
			"afPlastic    1.1.0  - 1.1",
			"afIoc        3.0.0  - 3.0", 
			"afIocConfig  1.1.0  - 1.1",
			"afIocEnv     1.1.0  - 1.1",
			
			// ---- Templating ------------------
			"afEfan       1.5.0  - 1.5"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `fan/public/advanced/`, `test/example/`, `test/unit-tests/`, `test/unit-tests/components/`]
		resDirs = [`doc/`, `test/example/`, `test/unit-tests/components/`]
	}
}
