import re

with open('lib/screens/admin_screen.dart', 'r') as f:
    content = f.read()

# We want to find the pattern:
#   @override
#   Widget build(BuildContext context) {
#     return Row(
#       children: [
#         Expanded(
#           flex: ...,
#           child: AppTheme.glassContainer(
#             context,
#             margin: ...,
# ...
#         Expanded(
#           flex: ...,
#           child: AppTheme.glassContainer(

def replacer(match):
    before = match.group(1)
    flex1 = match.group(2)
    form_content = match.group(3)
    margin2 = match.group(4)
    flex2 = match.group(5)
    list_content = match.group(6)
    
    return f"""{before}
    bool isWide = MediaQuery.of(context).size.width > 800;
    
    Widget formSection = AppTheme.glassContainer(
      context,
      margin: EdgeInsets.all(isWide ? 16 : 8),
{form_content}
    Widget listSection = AppTheme.glassContainer(
      context,
      margin: EdgeInsets.fromLTRB(isWide ? 0 : 8, isWide ? 16 : 8, isWide ? 16 : 8, isWide ? 16 : 8),
{list_content}
    if (isWide) {{
      return Row(
        children: [
          Expanded(flex: {flex1}, child: formSection),
          Expanded(flex: {flex2}, child: listSection),
        ],
      );
    }} else {{
      return Column(
        children: [
          Expanded(flex: 1, child: formSection),
          Expanded(flex: 1, child: listSection),
        ],
      );
    }}"""

# Note: this is tricky to regex correctly because of nested brackets.
# It's better to manually replace the build methods or use a more robust parser.

