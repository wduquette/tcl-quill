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
<node TEXT="How to do cross-platform builds" POSITION="right" ID="ID_1827986808" CREATED="1411674819752" MODIFIED="1411674828970">
<node TEXT="Build Modes" ID="ID_305693999" CREATED="1411674110965" MODIFIED="1411674113260">
<node TEXT="Build lib .zip" ID="ID_1339530422" CREATED="1411674113941" MODIFIED="1411674152113">
<node TEXT="" ID="ID_1788967665" CREATED="1411674162731" MODIFIED="1411674167766">
<icon BUILTIN="idea"/>
<node TEXT="All will be -tcl libs, since we don&apos;t support compiling" ID="ID_1713793081" CREATED="1411674171116" MODIFIED="1411674210696"/>
</node>
<node TEXT="For specific libs" ID="ID_616840424" CREATED="1411674131338" MODIFIED="1411674147694"/>
<node TEXT="For all libs" ID="ID_248110744" CREATED="1411674136208" MODIFIED="1411674138430"/>
</node>
<node TEXT="Build app" ID="ID_1051153038" CREATED="1411674118493" MODIFIED="1411674283492">
<node TEXT="As .kit (if pure Tcl)" ID="ID_1269315614" CREATED="1411674284136" MODIFIED="1411674296801"/>
<node TEXT="As exe for THIS platform" ID="ID_732307755" CREATED="1411674297240" MODIFIED="1411674306335"/>
<node TEXT="Build all" ID="ID_187449964" CREATED="1411674613638" MODIFIED="1411674618059">
<node TEXT="Run tests" ID="ID_728515049" CREATED="1411674618361" MODIFIED="1411674620915"/>
<node TEXT="Format docs" ID="ID_906069289" CREATED="1411674621477" MODIFIED="1411674630545"/>
<node TEXT="Build libs" ID="ID_1735086226" CREATED="1411674631279" MODIFIED="1411674636383"/>
<node TEXT="Build app for THIS platform" ID="ID_1379800892" CREATED="1411674636973" MODIFIED="1411674645783"/>
<node TEXT="Build dist for THIS platform" ID="ID_347913108" CREATED="1411674646214" MODIFIED="1411674664704"/>
</node>
<node TEXT="Build for another platform" ID="ID_252457486" CREATED="1411674306917" MODIFIED="1411674317243">
<node TEXT="Should only be done if &quot;build all&quot; succeeds this platform" ID="ID_91370719" CREATED="1411674503773" MODIFIED="1411674749302"/>
<node TEXT="Stopgap; better to build on the target platform." ID="ID_206423542" CREATED="1411674538256" MODIFIED="1411674549843"/>
<node TEXT="Available platforms determined by basekits at teapot." ID="ID_932339414" CREATED="1411674564884" MODIFIED="1411674595191"/>
<node TEXT="Build app and dist for target platform." ID="ID_31200673" CREATED="1411674717222" MODIFIED="1411674727099"/>
</node>
</node>
</node>
<node TEXT="Command Strings" ID="ID_814304044" CREATED="1411674840836" MODIFIED="1411674846120">
<node TEXT="quill build" ID="ID_422745646" CREATED="1411675571205" MODIFIED="1411752033635">
<icon BUILTIN="button_ok"/>
<node TEXT="all libs, all apps (kit, exe for this platform)" ID="ID_388330116" CREATED="1411675576451" MODIFIED="1411675599793"/>
</node>
<node TEXT="quill build lib" ID="ID_1150517015" CREATED="1411675602628" MODIFIED="1411752038720">
<icon BUILTIN="button_ok"/>
<node TEXT="all libs" ID="ID_1246078451" CREATED="1411675610682" MODIFIED="1411675612928"/>
</node>
<node TEXT="quill build lib names..." ID="ID_1785676489" CREATED="1411675615291" MODIFIED="1411752077443">
<icon BUILTIN="button_ok"/>
<node TEXT="These libs (kit, exe for this platform)" ID="ID_1861381149" CREATED="1411675622765" MODIFIED="1411675654225"/>
</node>
<node TEXT="quill build app" ID="ID_1987133634" CREATED="1411675625229" MODIFIED="1411752108035">
<icon BUILTIN="button_ok"/>
<node TEXT="all apps" ID="ID_1432117054" CREATED="1411675631486" MODIFIED="1411675634190"/>
</node>
<node TEXT="quill build app names..." ID="ID_1793022998" CREATED="1411675636822" MODIFIED="1411752108032">
<icon BUILTIN="button_ok"/>
<node TEXT="These apps" ID="ID_362418085" CREATED="1411675642205" MODIFIED="1411675659312">
<node TEXT="These libs (kit, exe for this platform)" ID="ID_1879047319" CREATED="1411675622765" MODIFIED="1411675654225"/>
</node>
</node>
<node TEXT="quill build all" ID="ID_1887224802" CREATED="1411675674264" MODIFIED="1411675698689">
<node TEXT="As listed above" ID="ID_368031278" CREATED="1411675678607" MODIFIED="1411675686957"/>
</node>
<node TEXT="quill build all -platform platform" ID="ID_857130843" CREATED="1411675699800" MODIFIED="1411675718446">
<node TEXT="Build for named platform (not this platform)" ID="ID_535531822" CREATED="1411675718851" MODIFIED="1411675728610"/>
</node>
<node TEXT="quill build platforms" ID="ID_1907554616" CREATED="1411675729981" MODIFIED="1411675735902">
<node TEXT="List possible exe platforms" ID="ID_1627023121" CREATED="1411675760157" MODIFIED="1411675766639"/>
</node>
</node>
<node TEXT="Project File Changes" ID="ID_159584158" CREATED="1411674846689" MODIFIED="1411674855799">
<node TEXT="-apptypes goes to -exetype." ID="ID_524173864" CREATED="1411674856550" MODIFIED="1411752018797">
<icon BUILTIN="button_ok"/>
</node>
<node TEXT="dist name gets a -%platform tag." ID="ID_845161218" CREATED="1411675518866" MODIFIED="1411752018800">
<icon BUILTIN="button_ok"/>
<node TEXT="&quot;tcl&quot; for .kits, actual platform for others." ID="ID_396542396" CREATED="1411675534578" MODIFIED="1411675548704"/>
</node>
<node TEXT="Building for another platform only works if -exetype is exe." ID="ID_1068809168" CREATED="1411674867930" MODIFIED="1411752014627"/>
</node>
</node>
</node>
</map>
