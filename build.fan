using build

class Build : BuildPod {

	new make() {
		podName = "afEfanXtra"
		summary = "A library for creating reusable Embedded Fantom (efan) components"
		version = Version("1.0.15")

		meta = [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "efanXtra",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afEfanXtra",			
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afefanxtra",
			"license.name"	: "The MIT Licence",
			"repo.private"	: "true",

			"tags"			: "templating",
			"afIoc.module"	: "afEfanXtra::EfanXtraModule"
		]

		index = [
			"afIoc.module"	: "afEfanXtra::EfanXtraModule" 
		]

		depends = [	
			"sys 1.0", 
			"concurrent 1.0",
			"fandoc 1.0",
			
			"afConcurrent 0+",
			"afIoc 1.6.0+", 
			"afIocConfig 1.0.4+", 
			"afEfan 1.3.8+", 
			"afPlastic 1.0.10+"
		]

		srcDirs = [`test/unit-tests/`, `test/unit-tests/internal/`, `test/unit-tests/internal/utils/`, `test/unit-tests/components/`, `test/example/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`licence.txt`, `doc/`, `res/`, `test/example/`, `test/unit-tests/components/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// see "stripTest" in `/etc/build/config.props` to exclude test src & res dirs
		super.compile
		
		// copy src to %FAN_HOME% for F4 debugging
		log.indent
		destDir := Env.cur.homeDir.plus(`src/${podName}/`)
		destDir.delete
		destDir.create		
		`fan/`.toFile.copyInto(destDir)		
		log.info("Copied `fan/` to ${destDir.normalize}")
		log.unindent
	}	
}