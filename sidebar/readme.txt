ColdBox SideBar

Install into your interceptors folder under a folder called "sidebar".  You can change the
location but you will need to then open the "ColdBoxSidebar.xml" and update the 

<!-- includes directory: normally interceptors/sidebar/includes/ -->
<Property name="includesDirectory">interceptors/sidebar/includes/</Property>

Then add to your interceptor definitions:

interceptors = [
	{class="interceptors.sidebar.ColdboxSideBar", properties = {} }
];