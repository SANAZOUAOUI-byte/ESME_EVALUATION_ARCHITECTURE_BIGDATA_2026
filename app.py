import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()
session.sql("USE DATABASE linkedin").collect()
session.sql("USE SCHEMA raw").collect()

st.set_page_config(page_title="Analyse LinkedIn", layout="wide")
st.title("Analyse des Offres d'Emploi LinkedIn")

def requete(sql):
    return session.sql(sql).to_pandas()

secteurs = requete("SELECT DISTINCT COALESCE(il.industry_name, ji.industry_id) AS industry_id FROM job_industries ji LEFT JOIN industry_labels il ON ji.industry_id = il.industry_id ORDER BY 1")["INDUSTRY_ID"].tolist()

onglet1, onglet2, onglet3, onglet4, onglet5 = st.tabs(["Top Titres", "Meilleurs Salaires", "Taille Entreprise", "Secteur", "Type Contrat"])

with onglet1:
    st.subheader("Top 10 des titres les plus publies par secteur")
    choix1 = st.selectbox("Secteur", secteurs, key="s1")
    sql1 = "WITH classement AS (SELECT COALESCE(il.industry_name, ji.industry_id) AS industrie, jp.title AS titre, COUNT(*) AS nb_offres, ROW_NUMBER() OVER (PARTITION BY ji.industry_id ORDER BY COUNT(*) DESC) AS rang FROM job_postings jp JOIN job_industries ji ON jp.job_id = ji.job_id LEFT JOIN industry_labels il ON ji.industry_id = il.industry_id GROUP BY ji.industry_id, il.industry_name, jp.title) SELECT titre, nb_offres FROM classement WHERE rang <= 10 AND industrie = '" + choix1 + "' ORDER BY nb_offres DESC"
    df1 = requete(sql1)
    st.bar_chart(df1.set_index("TITRE"), use_container_width=True)
    st.dataframe(df1, use_container_width=True)

with onglet2:
    st.subheader("Top 10 des postes les mieux remuneres par secteur")
    choix2 = st.selectbox("Secteur", secteurs, key="s2")
    sql2 = "WITH salaire_annuel AS (SELECT jp.title AS titre, COALESCE(il.industry_name, ji.industry_id) AS industrie, CASE jp.pay_period WHEN 'HOURLY' THEN jp.med_salary * 2080 WHEN 'MONTHLY' THEN jp.med_salary * 12 ELSE jp.med_salary END AS salaire_annuel FROM job_postings jp JOIN job_industries ji ON jp.job_id = ji.job_id LEFT JOIN industry_labels il ON ji.industry_id = il.industry_id WHERE jp.med_salary IS NOT NULL), classement AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY industrie ORDER BY salaire_annuel DESC) AS rang FROM salaire_annuel) SELECT titre, ROUND(salaire_annuel, 2) AS salaire_annuel_usd FROM classement WHERE rang <= 10 AND industrie = '" + choix2 + "' ORDER BY salaire_annuel_usd DESC"
    df2 = requete(sql2)
    st.bar_chart(df2.set_index("TITRE"), use_container_width=True)
    st.dataframe(df2, use_container_width=True)

with onglet3:
    st.subheader("Repartition des offres par taille d'entreprise")
    sql3 = "SELECT CASE c.company_size WHEN '0' THEN '1 employe' WHEN '1' THEN '2 a 10' WHEN '2' THEN '11 a 50' WHEN '3' THEN '51 a 200' WHEN '4' THEN '201 a 500' WHEN '5' THEN '501 a 1000' WHEN '6' THEN '1001 a 5000' WHEN '7' THEN '5000+' END AS taille_entreprise, COUNT(*) AS nb_offres FROM job_postings jp JOIN companies c ON SPLIT_PART(jp.company_name, '.', 1) = c.company_id GROUP BY c.company_size, taille_entreprise ORDER BY c.company_size"
    df3 = requete(sql3)
    st.bar_chart(df3.set_index("TAILLE_ENTREPRISE"), use_container_width=True)
    st.dataframe(df3, use_container_width=True)

with onglet4:
    st.subheader("Repartition des offres par secteur d'activite (Top 20)")
    sql4 = "SELECT COALESCE(il.industry_name, ji.industry_id) AS secteur, COUNT(*) AS nb_offres FROM job_postings jp JOIN job_industries ji ON jp.job_id = ji.job_id LEFT JOIN industry_labels il ON ji.industry_id = il.industry_id GROUP BY ji.industry_id, il.industry_name ORDER BY nb_offres DESC LIMIT 20"
    df4 = requete(sql4)
    st.bar_chart(df4.set_index("SECTEUR"), use_container_width=True)
    st.dataframe(df4, use_container_width=True)

with onglet5:
    st.subheader("Repartition des offres par type de contrat")
    sql5 = "SELECT formatted_work_type AS type_contrat, COUNT(*) AS nb_offres FROM job_postings WHERE formatted_work_type IS NOT NULL GROUP BY formatted_work_type ORDER BY nb_offres DESC"
    df5 = requete(sql5)
    st.bar_chart(df5.set_index("TYPE_CONTRAT"), use_container_width=True)
    st.dataframe(df5, use_container_width=True)