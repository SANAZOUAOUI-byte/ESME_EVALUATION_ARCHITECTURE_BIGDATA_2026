# Importation des bibliotheques Streamlit et Snowflake
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Connexion a la session Snowflake active
session = get_active_session()

# Selection de la base de donnees et du schema
session.sql("USE DATABASE linkedin").collect()
session.sql("USE SCHEMA raw").collect()

# Configuration de la page Streamlit
st.set_page_config(page_title="Analyse LinkedIn", layout="wide")

# Affichage du titre principal de l'application
st.title("Analyse des Offres d'Emploi LinkedIn")

# Fonction permettant d'executer une requete SQL
# puis de retourner le resultat sous forme de DataFrame
def requete(sql):
    return session.sql(sql).to_pandas()

# Execution d'une requete pour recuperer la liste des secteurs
secteurs = requete(
    "SELECT DISTINCT COALESCE(il.industry_name, ji.industry_id) AS industry_id "
    "FROM job_industries ji "
    "LEFT JOIN industry_labels il "
    "ON ji.industry_id = il.industry_id "
    "ORDER BY 1"
)["INDUSTRY_ID"].tolist()

# Creation des differents onglets de l'application
onglet1, onglet2, onglet3, onglet4, onglet5 = st.tabs([
    "Top Titres",
    "Meilleurs Salaires",
    "Taille Entreprise",
    "Secteur",
    "Type Contrat"
])

# ONGLET 1 
with onglet1:

    # Affichage du sous-titre
    st.subheader("Top 10 des titres les plus publies par secteur")

    # Affichage d'une liste deroulante pour choisir un secteur
    choix1 = st.selectbox("Secteur", secteurs, key="s1")

    # Requete SQL pour recuperer les titres les plus publies
    sql1 = "..."

    # Execution de la requete SQL
    df1 = requete(sql1)

    # Affichage du graphique des resultats
    st.bar_chart(df1.set_index("TITRE"), use_container_width=True)

    # Affichage du tableau des resultats
    st.dataframe(df1, use_container_width=True)


# ONGLET 2 
with onglet2:

    # Affichage du sous-titre
    st.subheader("Top 10 des postes les mieux remuneres par secteur")

    # Affichage d'une liste deroulante pour choisir un secteur
    choix2 = st.selectbox("Secteur", secteurs, key="s2")

    # Requete SQL pour calculer les meilleurs salaires
    sql2 = "..."

    # Execution de la requete SQL
    df2 = requete(sql2)

    # Affichage du graphique des salaires
    st.bar_chart(df2.set_index("TITRE"), use_container_width=True)

    # Affichage du tableau des resultats
    st.dataframe(df2, use_container_width=True)


# ONGLET 3 
with onglet3:

    # Affichage du sous-titre
    st.subheader("Repartition des offres par taille d'entreprise")

    # Requete SQL pour compter les offres par taille d'entreprise
    sql3 = "..."

    # Execution de la requete SQL
    df3 = requete(sql3)

    # Affichage du graphique
    st.bar_chart(df3.set_index("TAILLE_ENTREPRISE"), use_container_width=True)

    # Affichage du tableau
    st.dataframe(df3, use_container_width=True)


# ONGLET 4 
with onglet4:

    # Affichage du sous-titre
    st.subheader("Repartition des offres par secteur d'activite")

    # Requete SQL pour recuperer les secteurs les plus representes
    sql4 = "..."

    # Execution de la requete SQL
    df4 = requete(sql4)

    # Affichage du graphique
    st.bar_chart(df4.set_index("SECTEUR"), use_container_width=True)

    # Affichage du tableau
    st.dataframe(df4, use_container_width=True)


#  ONGLET 5 
with onglet5:

    # Affichage du sous-titre
    st.subheader("Repartition des offres par type de contrat")

    # Requete SQL pour compter les types de contrats
    sql5 = "..."

    # Execution de la requete SQL
    df5 = requete(sql5)

    # Affichage du graphique
    st.bar_chart(df5.set_index("TYPE_CONTRAT"), use_container_width=True)

    # Affichage du tableau
    st.dataframe(df5, use_container_width=True)
