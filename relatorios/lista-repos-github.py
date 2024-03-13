import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.graph_objs as go

# Read CSV data
df = pd.read_csv('lista-repos-github.csv')

# Split Languages column into separate rows
df['Languages'] = df['Languages'].str.split(',')
df = df.explode('Languages')

# Count occurrences of each language
language_counts = df['Languages'].value_counts()

# Plot bar chart for language distribution
plt.figure(figsize=(10, 6))
sns.barplot(x=language_counts.index, y=language_counts.values, palette='viridis')
plt.title('Language Distribution')
plt.xlabel('Language')
plt.ylabel('Count')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig('language_distribution.png')

# Count repositories by number of languages
repo_language_counts = df.groupby('Repository')['Languages'].nunique()

# Plot histogram for number of languages per repository
plt.figure(figsize=(8, 6))
sns.histplot(repo_language_counts, bins=range(1, repo_language_counts.max() + 2), discrete=True, color='skyblue')
plt.title('Number of Languages per Repository')
plt.xlabel('Number of Languages')
plt.ylabel('Count of Repositories')
plt.xticks(range(1, repo_language_counts.max() + 1))
plt.tight_layout()
plt.savefig('languages_per_repo.png')

# Create interactive pie chart for language distribution
language_pie_chart = go.Pie(labels=language_counts.index, values=language_counts.values)
language_pie_chart_layout = go.Layout(title='Language Distribution')
language_pie_chart_fig = go.Figure(data=[language_pie_chart], layout=language_pie_chart_layout)
language_pie_chart_html = language_pie_chart_fig.to_html(full_html=False)

# Create HTML page
html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analysis</title>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
</head>
<body>
    <h1>Analysis of Repository Data</h1>
    <h2>Language Distribution</h2>
    <div id="language_pie_chart">{language_pie_chart_html}</div>
    <img src="language_distribution.png" alt="Language Distribution" width="600">
    <h2>Number of Languages per Repository</h2>
    <img src="languages_per_repo.png" alt="Languages per Repository" width="600">
</body>
</html>
"""

# Save HTML content to a file named lista-repos-github.html
with open('lista-repos-github.html', 'w') as file:
    file.write(html_content)