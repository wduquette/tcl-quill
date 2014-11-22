<map version="freeplane 1.2.0">
<!--To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net -->
<node TEXT="Quill Notes" ID="ID_1723255651" CREATED="1283093380553" MODIFIED="1411674110340"><hook NAME="MapStyle" zoom="1.5">

<map_styles>
<stylenode LOCALIZED_TEXT="styles.root_node">
<stylenode LOCALIZED_TEXT="styles.predefined" POSITION="right">
<stylenode LOCALIZED_TEXT="default" MAX_WIDTH="600" COLOR="#000000" STYLE="as_parent">
<font NAME="SansSerif" SIZE="10" BOLD="false" ITALIC="false"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.details"/>
<stylenode LOCALIZED_TEXT="defaultstyle.note"/>
<stylenode LOCALIZED_TEXT="defaultstyle.floating">
<edge STYLE="hide_edge"/>
<cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="right">
<stylenode LOCALIZED_TEXT="styles.topic" COLOR="#18898b" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subtopic" COLOR="#cc3300" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subsubtopic" COLOR="#669900">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.important">
<icon BUILTIN="yes"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="right">
<stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#000000">
<font SIZE="18"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#0033ff">
<font SIZE="16"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#00b439">
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#990000">
<font SIZE="12"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#111111">
<font SIZE="10"/>
</stylenode>
</stylenode>
</stylenode>
</map_styles>
</hook>
<node TEXT="quill new/add" POSITION="right" ID="ID_1534602844" CREATED="1415556853885" MODIFIED="1415556888507">
<node TEXT="-force option" ID="ID_770290599" CREATED="1415556900784" MODIFIED="1415556903530">
<node TEXT="-force will create the template files in an existing directory" ID="ID_454127411" CREATED="1415556903980" MODIFIED="1415556919616"/>
<node TEXT="This is useful when working with github" ID="ID_580736721" CREATED="1415556919988" MODIFIED="1415556929625">
<node TEXT="Create empty repository" ID="ID_1120907058" CREATED="1415556930004" MODIFIED="1415556936453"/>
<node TEXT="Clone it to local disk" ID="ID_1198918555" CREATED="1415556936720" MODIFIED="1415556939710"/>
<node TEXT="quill new -force to populate it." ID="ID_1614267496" CREATED="1415556940039" MODIFIED="1415556947452"/>
</node>
</node>
<node TEXT="Templates" ID="ID_748712912" CREATED="1415556889038" MODIFIED="1415556892934">
<node TEXT="Terminology" ID="ID_777772200" CREATED="1415557001933" MODIFIED="1415925951856">
<node TEXT="File" ID="ID_1468840106" CREATED="1415925817184" MODIFIED="1415925818647">
<node TEXT="A single file template, implemented using maptemplate" ID="ID_1643470743" CREATED="1415925824714" MODIFIED="1415925833468"/>
<node TEXT="Default templates are in qfiles.tcl and ::qfile namespace." ID="ID_1265826299" CREATED="1415925833742" MODIFIED="1415925853441"/>
<node TEXT="No special command needed; maptemplate is good enough." ID="ID_1859169081" CREATED="1415925853827" MODIFIED="1415925873990"/>
</node>
<node TEXT="File Set" ID="ID_1569553908" CREATED="1415925875905" MODIFIED="1415925878210">
<node TEXT="A set of files in a project tree" ID="ID_626430694" CREATED="1415925879045" MODIFIED="1415925888819"/>
<node TEXT="Can include files" ID="ID_1789016920" CREATED="1415925889348" MODIFIED="1415925897206"/>
<node TEXT="Can include other file sets" ID="ID_1963432906" CREATED="1415925897586" MODIFIED="1415925907610"/>
<node TEXT="Can also" ID="ID_12191938" CREATED="1415925918837" MODIFIED="1415925921835">
<node TEXT="?" ID="ID_5359362" CREATED="1415925922174" MODIFIED="1415925923008"/>
</node>
</node>
<node TEXT="Tree" ID="ID_633603218" CREATED="1415556893505" MODIFIED="1415556895137">
<node TEXT="For complete project trees" ID="ID_336654925" CREATED="1415556955662" MODIFIED="1415556967540"/>
<node TEXT="Built up of file sets and files" ID="ID_1717268240" CREATED="1415556967843" MODIFIED="1415925939749"/>
</node>
</node>
<node TEXT="Architecture" ID="ID_1609066840" CREATED="1415557008222" MODIFIED="1415557010355">
<node TEXT="Define a &quot;tool&quot;-like command for defining File Sets and Trees" ID="ID_447602991" CREATED="1415557010711" MODIFIED="1415925986286"/>
<node TEXT="Incorporates help information, metadata, and code." ID="ID_951283565" CREATED="1415557031806" MODIFIED="1415557044659"/>
<node TEXT="Metadata includes" ID="ID_1427777246" CREATED="1415557205395" MODIFIED="1415557210883">
<node TEXT="Required parameters" ID="ID_249121872" CREATED="1415557225875" MODIFIED="1415557228895"/>
<node TEXT="Options" ID="ID_516851960" CREATED="1415557211247" MODIFIED="1415557219990"/>
</node>
<node TEXT="Basis for template plug-ins" ID="ID_374246834" CREATED="1415557045284" MODIFIED="1415557051569"/>
<node TEXT="File templates" ID="ID_426683945" CREATED="1415926009067" MODIFIED="1415926013367">
<node TEXT="Return a file&apos;s contents given parameters and project metadata." ID="ID_1430782068" CREATED="1415926013761" MODIFIED="1415926034704"/>
</node>
<node TEXT="File Set templates" ID="ID_1470983214" CREATED="1415557955599" MODIFIED="1415926008245">
<node TEXT="Define files and their contents" ID="ID_913761559" CREATED="1415557970474" MODIFIED="1415926043372"/>
<node TEXT="Includes files and file sets" ID="ID_1097926839" CREATED="1415557972853" MODIFIED="1415926096553"/>
<node TEXT="Update project metadata" ID="ID_1885530572" CREATED="1415557979831" MODIFIED="1415557991138"/>
</node>
<node TEXT="Tree templates" ID="ID_93821567" CREATED="1415558008060" MODIFIED="1415926053170">
<node TEXT="Define project metadata and the whole tree." ID="ID_1711871401" CREATED="1415926062591" MODIFIED="1415926079237"/>
<node TEXT="Include files and file sets" ID="ID_389802961" CREATED="1415558016651" MODIFIED="1415926085477"/>
<node TEXT="Update project metadata" ID="ID_1264556838" CREATED="1415558037635" MODIFIED="1415558043739"/>
</node>
<node TEXT="quill new must" ID="ID_903079005" CREATED="1415558046075" MODIFIED="1415558050318">
<node TEXT="Accept the new project&apos;s directory name" ID="ID_1927316660" CREATED="1415558091705" MODIFIED="1415558146090"/>
<node TEXT="Refuse to operate within an existing project tree, unless -force" ID="ID_509762974" CREATED="1415558148291" MODIFIED="1415558266260"/>
<node TEXT="Refuse to overwrite an existing directory, unless -force" ID="ID_1293806426" CREATED="1415558160283" MODIFIED="1415558171627"/>
<node TEXT="Accept the name of a tree template" ID="ID_422192060" CREATED="1415558050650" MODIFIED="1415558076067">
<node TEXT="With required parameters" ID="ID_404917088" CREATED="1415558077353" MODIFIED="1415558080321"/>
<node TEXT="And options" ID="ID_864121021" CREATED="1415558080721" MODIFIED="1415558082163"/>
<node TEXT="As defined in the tree template" ID="ID_359519164" CREATED="1415558082445" MODIFIED="1415558090583"/>
</node>
<node TEXT="Initialize the project metadata" ID="ID_235432194" CREATED="1415558177110" MODIFIED="1415558205847"/>
<node TEXT="Have the tree build itself" ID="ID_1067781144" CREATED="1415558206314" MODIFIED="1415558217022">
<node TEXT="Updates project metadata further" ID="ID_729741418" CREATED="1415558217431" MODIFIED="1415558221346"/>
</node>
<node TEXT="Save the project metadata into the project.quill file." ID="ID_1230058295" CREATED="1415558222994" MODIFIED="1415558231265"/>
</node>
<node TEXT="quill add must" ID="ID_126072641" CREATED="1415558234219" MODIFIED="1415558237875">
<node TEXT="Load the project metadata from disk." ID="ID_253275259" CREATED="1415558238306" MODIFIED="1415558245918"/>
<node TEXT="Refuse to operate outside of an existing project tree" ID="ID_1379710139" CREATED="1415558246397" MODIFIED="1415558257144"/>
<node TEXT="Refuse to overwrite existing directories/files unless -force" ID="ID_1850668457" CREATED="1415558268769" MODIFIED="1415558284042">
<node TEXT="The element must be able to rule on whether it would overwrite or not." ID="ID_1976697088" CREATED="1415558383059" MODIFIED="1415558396272"/>
</node>
<node TEXT="Accept any element name" ID="ID_871665421" CREATED="1415558286192" MODIFIED="1415558309252">
<node TEXT="With required parameters" ID="ID_699388047" CREATED="1415558309653" MODIFIED="1415558314007"/>
<node TEXT="And options" ID="ID_1376671960" CREATED="1415558314305" MODIFIED="1415558315968"/>
<node TEXT="As defined in the element template" ID="ID_1828453261" CREATED="1415558316244" MODIFIED="1415558320849"/>
</node>
<node TEXT="Have the element build itself" ID="ID_1292122575" CREATED="1415558323941" MODIFIED="1415558332535">
<node TEXT="Possibly updating project metadata" ID="ID_1841306007" CREATED="1415558354870" MODIFIED="1415558363950"/>
</node>
<node TEXT="Save the project metadata into the project.quill file." ID="ID_835784974" CREATED="1415558364730" MODIFIED="1415558374693"/>
</node>
</node>
<node TEXT="Existing File Templates" ID="ID_1828060087" CREATED="1415926134753" MODIFIED="1415926138453">
<node TEXT="pkgIndex.tcl" ID="ID_1046843059" CREATED="1415926184438" MODIFIED="1415926188758"/>
<node TEXT="pkgModules.tcl" ID="ID_1574000821" CREATED="1415926189289" MODIFIED="1415926193147"/>
<node TEXT="module.tcl" ID="ID_563379382" CREATED="1415926193942" MODIFIED="1415926195755"/>
<node TEXT="main.tcl" ID="ID_1963592615" CREATED="1415926196071" MODIFIED="1415926197671"/>
<node TEXT="all_tests.test" ID="ID_1838396520" CREATED="1415926198703" MODIFIED="1415926200826"/>
<node TEXT="testfile.test" ID="ID_35218955" CREATED="1415926201139" MODIFIED="1415926204164"/>
<node TEXT="app.tcl" ID="ID_1870569051" CREATED="1415926204473" MODIFIED="1415926207059"/>
<node TEXT="man1.manpage" ID="ID_746256560" CREATED="1415926207439" MODIFIED="1415926210878"/>
<node TEXT="mann.manpage" ID="ID_1607644069" CREATED="1415926211167" MODIFIED="1415926216171"/>
<node TEXT="quillinfoPkgIndex" ID="ID_1365655337" CREATED="1415926216669" MODIFIED="1415926243118"/>
<node TEXT="quillinfoPkgModules" ID="ID_1144418585" CREATED="1415926243818" MODIFIED="1415926247616"/>
<node TEXT="quillinfo.tcl" ID="ID_183981036" CREATED="1415926247978" MODIFIED="1415926252878"/>
<node TEXT="README.md" ID="ID_1839271596" CREATED="1415926253251" MODIFIED="1415926255825"/>
<node TEXT="index.quilldoc" ID="ID_7631413" CREATED="1415926258149" MODIFIED="1415926264514"/>
</node>
<node TEXT="Existing File Sets" ID="ID_669127306" CREATED="1415557078971" MODIFIED="1415926286956">
<node TEXT="app" ID="ID_426475283" CREATED="1415926304943" MODIFIED="1415926309943"/>
<node TEXT="package" ID="ID_1955818247" CREATED="1415926311091" MODIFIED="1415926312972"/>
<node TEXT="quillinfo" ID="ID_1869323326" CREATED="1415926313761" MODIFIED="1415926316963"/>
</node>
<node TEXT="Existing File Sets" ID="ID_851474795" CREATED="1415557078971" MODIFIED="1415926286956">
<node TEXT="quillinfo package" ID="ID_53562988" CREATED="1415557418026" MODIFIED="1415926122538" VSHIFT="18">
<node TEXT="lib/quillinfo" ID="ID_1084953782" CREATED="1415557541778" MODIFIED="1415557546173"/>
<node TEXT="quillInfoPkgIndex" ID="ID_1333307832" CREATED="1415557476829" MODIFIED="1415926402658"/>
<node TEXT="quillinfoPkgModules" ID="ID_536552502" CREATED="1415557484572" MODIFIED="1415926414445"/>
<node TEXT="quillinfo.tcl" ID="ID_274712328" CREATED="1415557487155" MODIFIED="1415557489762"/>
</node>
<node TEXT="library directory" ID="ID_373588307" CREATED="1415557089137" MODIFIED="1415557670540">
<node TEXT="lib/{name}" ID="ID_8692737" CREATED="1415557521074" MODIFIED="1415557530456"/>
<node TEXT="pkgIndex.tcl" ID="ID_1769017551" CREATED="1415557491236" MODIFIED="1415557493608"/>
<node TEXT="pkgModules.tcl" ID="ID_1123282410" CREATED="1415557494348" MODIFIED="1415557496587"/>
<node TEXT="module.tcl =&gt; {name}" ID="ID_114435795" CREATED="1415557497355" MODIFIED="1415926475711"/>
</node>
<node TEXT="application implementation package directory" ID="ID_245069163" CREATED="1415557100781" MODIFIED="1415557679295">
<node TEXT="lib/app_{name}" ID="ID_43479360" CREATED="1415557571237" MODIFIED="1415557576273"/>
<node TEXT="pkgIndex.tcl" ID="ID_1690247463" CREATED="1415557576879" MODIFIED="1415557580189"/>
<node TEXT="pkgModules.tcl" ID="ID_870475573" CREATED="1415557580472" MODIFIED="1415557582841"/>
<node TEXT="main.tcl" ID="ID_798514207" CREATED="1415557583329" MODIFIED="1415557585772"/>
</node>
<node TEXT="test target" ID="ID_1303390627" CREATED="1415557611630" MODIFIED="1415557621331">
<node TEXT="test/{name}" ID="ID_1964146041" CREATED="1415557625104" MODIFIED="1415557628057"/>
<node TEXT="all_tests.test" ID="ID_737348428" CREATED="1415557628417" MODIFIED="1415557646369"/>
<node TEXT="testfile =&gt; {name}.test" ID="ID_1045046671" CREATED="1415557646873" MODIFIED="1415926494640"/>
</node>
<node TEXT="library package" ID="ID_224424319" CREATED="1415557697189" MODIFIED="1415557702235">
<node TEXT="library directory" ID="ID_838781192" CREATED="1415557702808" MODIFIED="1415557707341"/>
<node TEXT="test target" ID="ID_1870817947" CREATED="1415557707707" MODIFIED="1415557709686"/>
</node>
<node TEXT="application" ID="ID_1974030028" CREATED="1415557710699" MODIFIED="1415557719151">
<node TEXT="loader script" ID="ID_1131161025" CREATED="1415557719876" MODIFIED="1415557751922">
<node TEXT="app.tcl =&gt; bin/{name}.tcl" ID="ID_847841742" CREATED="1415557754929" MODIFIED="1415926527321"/>
</node>
<node TEXT="man page" ID="ID_657037424" CREATED="1415557760154" MODIFIED="1415557761965">
<node TEXT="man1.manpage =&gt; docs/man1/{name}.manpage" ID="ID_14424540" CREATED="1415557763042" MODIFIED="1415926545301"/>
</node>
<node TEXT="application implementation package" ID="ID_107641505" CREATED="1415557798276" MODIFIED="1415557804822"/>
</node>
<node TEXT="project readme" ID="ID_272830602" CREATED="1415557903405" MODIFIED="1415557911733">
<node TEXT="README.md" ID="ID_100047830" CREATED="1415557912082" MODIFIED="1415557915288"/>
</node>
<node TEXT="project docs index" ID="ID_1471649506" CREATED="1415557916275" MODIFIED="1415557920063">
<node TEXT="docs/index.quilldoc" ID="ID_388800395" CREATED="1415557920814" MODIFIED="1415557929265"/>
</node>
</node>
<node TEXT="Existing Trees" ID="ID_1859986523" CREATED="1415926633211" MODIFIED="1415926635959">
<node TEXT="app" ID="ID_450594820" CREATED="1415926636291" MODIFIED="1415926638767"/>
</node>
</node>
<node TEXT="Next Step" ID="ID_831595068" CREATED="1415926659127" MODIFIED="1415926662720">
<node TEXT="Make tree_app an elementx in trees." ID="ID_1575004115" CREATED="1416004425018" MODIFIED="1416004436833"/>
<node TEXT="Add a lib elementx in trees, and test both of them." ID="ID_293284627" CREATED="1416004437237" MODIFIED="1416004448990"/>
<node TEXT="Need to be able to save the project file." ID="ID_1029399540" CREATED="1415926663246" MODIFIED="1415926703541"/>
<node TEXT="Commands to initialize new project directory" ID="ID_1065725005" CREATED="1415926704093" MODIFIED="1415926721221"/>
<node TEXT="Commands to add metadata" ID="ID_489557565" CREATED="1415926721665" MODIFIED="1415926727645"/>
<node TEXT="Command to save metadata" ID="ID_1102463009" CREATED="1415926728587" MODIFIED="1415926735598"/>
</node>
<node TEXT="Existing Actions" ID="ID_987446187" CREATED="1415926772814" MODIFIED="1415926778008">
<node TEXT="element_app" ID="ID_1903952463" CREATED="1415926778232" MODIFIED="1415926810872">
<node TEXT="create files using file templates." ID="ID_1838515856" CREATED="1415926782502" MODIFIED="1415926789522"/>
<node TEXT="create files using element_package" ID="ID_794621367" CREATED="1415926789868" MODIFIED="1415926805063"/>
<node TEXT="Mark bin/$app.tcl as executable" ID="ID_94876597" CREATED="1415926812640" MODIFIED="1415926821987"/>
</node>
<node TEXT="element_package" ID="ID_1311692595" CREATED="1415926834440" MODIFIED="1415926837451">
<node TEXT="create files using file templates." ID="ID_184891285" CREATED="1415926837794" MODIFIED="1415926847202"/>
</node>
<node TEXT="element_quillinfo" ID="ID_435046476" CREATED="1415926861321" MODIFIED="1415926868698">
<node TEXT="create files" ID="ID_1887660876" CREATED="1415926870457" MODIFIED="1415926874643"/>
</node>
</node>
<node TEXT="Observations" ID="ID_646981537" CREATED="1415926881817" MODIFIED="1415926884184">
<node TEXT="Aha!  a file set is not an element!" ID="ID_273638042" CREATED="1415926884613" MODIFIED="1415926891907"/>
<node TEXT="A file set is a file set.  An element is a thing you can add" ID="ID_61414779" CREATED="1415926893029" MODIFIED="1415926908647"/>
<node TEXT="Tree and branch elements use file sets" ID="ID_87880603" CREATED="1415926912010" MODIFIED="1415926926522"/>
<node TEXT="Updating project metadata is an aspect of the &quot;quill new&quot; and &quot;quill add&quot; commands" ID="ID_1363936484" CREATED="1415926940569" MODIFIED="1415926962145"/>
<node TEXT="Project metadata is associated with tree and branch objects, not file sets." ID="ID_1906036803" CREATED="1415926962722" MODIFIED="1415926980117"/>
</node>
</node>
</node>
</map>
