using build

class Build : BuildPod {

	new make() {
		podName = "afEfanXtra"
		summary = "A library for creating reusable Embedded Fantom (efan) components"
		version = Version("2.0.2")

		meta = [
			"pod.dis"		: "efanXtra",
			"afIoc.module"	: "afEfanXtra::EfanXtraModule",
			"repo.tags"		: "templating",
			"repo.public"	: "true"
		]

		index = [
			"afIoc.module"	: "afEfanXtra::EfanXtraModule" 
		]

		depends = [	
			"sys          1.0.69 - 1.0", 
			"concurrent   1.0.69 - 1.0",
			"fandoc       1.0.69 - 1.0",
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.10 - 1.0",
			"afConcurrent 1.0.24 - 1.0",
			"afPlastic    1.1.6  - 1.1",
			"afIoc        3.0.6  - 3.0", 
			"afIocConfig  1.1.0  - 1.1",
			"afIocEnv     1.1.0  - 1.1",
			
			// ---- Templating ------------------
			"afEfan       2.0.4  - 2.0",
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/utils/`, `fan/public/`, `fan/public/advanced/`, `test/example/`, `test/unit-tests/`, `test/unit-tests/components/`]
		resDirs = [`doc/`, `test/example/`, `test/unit-tests/components/`]
	}
}
