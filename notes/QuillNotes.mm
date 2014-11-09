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
<node TEXT="Categories" ID="ID_777772200" CREATED="1415557001933" MODIFIED="1415557076451">
<node TEXT="Tree" ID="ID_633603218" CREATED="1415556893505" MODIFIED="1415556895137">
<node TEXT="For complete project trees" ID="ID_336654925" CREATED="1415556955662" MODIFIED="1415556967540"/>
<node TEXT="Built up of elements" ID="ID_1717268240" CREATED="1415556967843" MODIFIED="1415556975141"/>
</node>
<node TEXT="Element" ID="ID_832304594" CREATED="1415556895409" MODIFIED="1415556897061">
<node TEXT="For part of a project" ID="ID_841174985" CREATED="1415556982793" MODIFIED="1415556985849"/>
<node TEXT="Adds a single element" ID="ID_179196284" CREATED="1415556986116" MODIFIED="1415556989222"/>
<node TEXT="The element can comprise multiple elements." ID="ID_939271075" CREATED="1415557143224" MODIFIED="1415557159885"/>
</node>
</node>
<node TEXT="Architecture" ID="ID_1609066840" CREATED="1415557008222" MODIFIED="1415557010355">
<node TEXT="Define a &quot;tool&quot;-like command for defining templates" ID="ID_447602991" CREATED="1415557010711" MODIFIED="1415557031342"/>
<node TEXT="Incorporates help information, metadata, and code." ID="ID_951283565" CREATED="1415557031806" MODIFIED="1415557044659"/>
<node TEXT="Metadata includes" ID="ID_1427777246" CREATED="1415557205395" MODIFIED="1415557210883">
<node TEXT="Required parameters" ID="ID_249121872" CREATED="1415557225875" MODIFIED="1415557228895"/>
<node TEXT="Options" ID="ID_516851960" CREATED="1415557211247" MODIFIED="1415557219990"/>
</node>
<node TEXT="Basis for template plug-ins" ID="ID_374246834" CREATED="1415557045284" MODIFIED="1415557051569"/>
<node TEXT="Element templates can" ID="ID_1470983214" CREATED="1415557955599" MODIFIED="1415557970061">
<node TEXT="Define files" ID="ID_913761559" CREATED="1415557970474" MODIFIED="1415557972466"/>
<node TEXT="Include other elements" ID="ID_1097926839" CREATED="1415557972853" MODIFIED="1415557979483"/>
<node TEXT="Update project metadata" ID="ID_1885530572" CREATED="1415557979831" MODIFIED="1415557991138"/>
</node>
<node TEXT="Tree templates must" ID="ID_93821567" CREATED="1415558008060" MODIFIED="1415558036607">
<node TEXT="Include elements" ID="ID_389802961" CREATED="1415558016651" MODIFIED="1415558019814"/>
<node TEXT="Update project metadata" ID="ID_1264556838" CREATED="1415558037635" MODIFIED="1415558043739"/>
</node>
<node TEXT="template operations" ID="ID_1042189868" CREATED="1415558461779" MODIFIED="1415558464820">
<node TEXT="validate {arglist}" ID="ID_1948568590" CREATED="1415558599191" MODIFIED="1415558605040">
<node TEXT="Validate the template&apos;s arguments" ID="ID_1612460646" CREATED="1415558605615" MODIFIED="1415558619780"/>
<node TEXT="Throw INVALID with good error message if invalid." ID="ID_943272223" CREATED="1415558620061" MODIFIED="1415558631043"/>
<node TEXT="Parent class does standard validation based on metadata" ID="ID_609507489" CREATED="1415558631828" MODIFIED="1415558677258"/>
</node>
<node TEXT="check ?-force?" ID="ID_1120962811" CREATED="1415558465179" MODIFIED="1415558493666">
<node TEXT="Can the template operate?" ID="ID_1782321373" CREATED="1415558474542" MODIFIED="1415558485777"/>
<node TEXT="Return &quot;&quot; if it can" ID="ID_366633989" CREATED="1415558498180" MODIFIED="1415558518820"/>
<node TEXT="Return error message if it can&apos;t." ID="ID_896242270" CREATED="1415558519091" MODIFIED="1415558526334"/>
</node>
<node TEXT="execute {parms...} ?{options...}?" ID="ID_1854446473" CREATED="1415558539492" MODIFIED="1415558573768">
<node TEXT="Build the templated files given the arguments." ID="ID_164537522" CREATED="1415558574377" MODIFIED="1415558582095"/>
</node>
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
<node TEXT="Existing Element Types" ID="ID_669127306" CREATED="1415557078971" MODIFIED="1415557087852">
<node TEXT="quillinfo package" ID="ID_317855671" CREATED="1415557418026" MODIFIED="1415557538085" HGAP="30" VSHIFT="24">
<node TEXT="lib/quillinfo" ID="ID_1812346450" CREATED="1415557541778" MODIFIED="1415557546173"/>
<node TEXT="pkgIndex.tcl" ID="ID_493940697" CREATED="1415557476829" MODIFIED="1415557484197"/>
<node TEXT="pkgModules.tcl" ID="ID_1913471777" CREATED="1415557484572" MODIFIED="1415557486797"/>
<node TEXT="quillinfo.tcl" ID="ID_1685880677" CREATED="1415557487155" MODIFIED="1415557489762"/>
</node>
<node TEXT="library directory" ID="ID_55905069" CREATED="1415557089137" MODIFIED="1415557670540">
<node TEXT="lib/{name}" ID="ID_1702811719" CREATED="1415557521074" MODIFIED="1415557530456"/>
<node TEXT="pkgIndex.tcl" ID="ID_152150035" CREATED="1415557491236" MODIFIED="1415557493608"/>
<node TEXT="pkgModules.tcl" ID="ID_1374797915" CREATED="1415557494348" MODIFIED="1415557496587"/>
<node TEXT="{lib}.tcl" ID="ID_1380209763" CREATED="1415557497355" MODIFIED="1415557506830"/>
</node>
<node TEXT="application implementation package directory" ID="ID_1072460337" CREATED="1415557100781" MODIFIED="1415557679295">
<node TEXT="lib/app_{name}" ID="ID_691923453" CREATED="1415557571237" MODIFIED="1415557576273"/>
<node TEXT="pkgIndex.tcl" ID="ID_132936593" CREATED="1415557576879" MODIFIED="1415557580189"/>
<node TEXT="pkgModules.tcl" ID="ID_1837620830" CREATED="1415557580472" MODIFIED="1415557582841"/>
<node TEXT="main.tcl" ID="ID_572074284" CREATED="1415557583329" MODIFIED="1415557585772"/>
</node>
<node TEXT="test target" ID="ID_1264512662" CREATED="1415557611630" MODIFIED="1415557621331">
<node TEXT="test/{name}" ID="ID_475094541" CREATED="1415557625104" MODIFIED="1415557628057"/>
<node TEXT="all_tests.test" ID="ID_1682803583" CREATED="1415557628417" MODIFIED="1415557646369"/>
<node TEXT="{name}.test" ID="ID_488559007" CREATED="1415557646873" MODIFIED="1415557656731"/>
</node>
<node TEXT="library package" ID="ID_1140999907" CREATED="1415557697189" MODIFIED="1415557702235">
<node TEXT="library directory" ID="ID_690966102" CREATED="1415557702808" MODIFIED="1415557707341"/>
<node TEXT="test target" ID="ID_1916133135" CREATED="1415557707707" MODIFIED="1415557709686"/>
</node>
<node TEXT="application" ID="ID_522221067" CREATED="1415557710699" MODIFIED="1415557719151">
<node TEXT="loader script" ID="ID_693512173" CREATED="1415557719876" MODIFIED="1415557751922">
<node TEXT="bin/{name}.tcl" ID="ID_559684771" CREATED="1415557754929" MODIFIED="1415557758926"/>
</node>
<node TEXT="man page" ID="ID_1647498829" CREATED="1415557760154" MODIFIED="1415557761965">
<node TEXT="docs/man1/{name}.manpage" ID="ID_539872895" CREATED="1415557763042" MODIFIED="1415557773833"/>
</node>
<node TEXT="application implementation package" ID="ID_1729596435" CREATED="1415557798276" MODIFIED="1415557804822"/>
</node>
<node TEXT="project readme" ID="ID_763722789" CREATED="1415557903405" MODIFIED="1415557911733">
<node TEXT="README.md" ID="ID_822784859" CREATED="1415557912082" MODIFIED="1415557915288"/>
</node>
<node TEXT="project docs index" ID="ID_115483159" CREATED="1415557916275" MODIFIED="1415557920063">
<node TEXT="docs/index.quilldoc" ID="ID_992654350" CREATED="1415557920814" MODIFIED="1415557929265"/>
</node>
</node>
</node>
<node TEXT="Questions" ID="ID_168963120" CREATED="1415557162155" MODIFIED="1415557164191">
<node TEXT="Should every individual file be a distinct element?" ID="ID_639902596" CREATED="1415557164464" MODIFIED="1415557196111">
<node TEXT="Don&apos;t require this..." ID="ID_1125250757" CREATED="1415558409718" MODIFIED="1415558414376"/>
<node TEXT="But consider doing it in practice" ID="ID_21889227" CREATED="1415558414812" MODIFIED="1415558422848"/>
</node>
</node>
</node>
</node>
</map>
