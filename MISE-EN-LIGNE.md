# Orbite — mise en ligne

Trois étapes, environ dix minutes. Tu as besoin d'un compte Supabase et d'un compte Vercel.

---

## 1. Créer la base

1. Va sur **supabase.com** → *New project*.
2. Nomme-le `orbite`, choisis une région proche (Frankfurt ou Paris), et note ton mot de passe de base de données quelque part de sûr — tu n'en auras pas besoin pour l'application, mais Supabase te le demandera un jour.
3. Attends la fin de l'initialisation (environ deux minutes).
4. Ouvre **SQL Editor** → *New query*, colle tout le contenu de `schema.sql`, puis **Run**.

Tu dois voir `Success. No rows returned`. La table `tasks` existe, et personne ne peut lire les tâches d'un autre : les politiques RLS l'interdisent au niveau de la base, pas seulement dans l'application.

## 2. Récupérer tes deux clés

Dans **Project Settings → Data API** :

- **Project URL** → ressemble à `https://abcdefgh.supabase.co`
- **anon public** → une longue chaîne commençant par `eyJ...`

Ouvre `index.html`, tout en haut, et remplis le bloc :

```js
window.ORBITE_CONFIG = {
  url:     'https://abcdefgh.supabase.co',
  anonKey: 'eyJ...'
};
```

Ces deux valeurs sont publiques par conception. La clé `anon` ne donne aucun droit par elle-même : c'est la session de l'utilisateur connecté, combinée aux politiques RLS, qui autorise l'accès. Ne mets **jamais** la clé `service_role` dans ce fichier.

## 3. Confirmation d'e-mail

Par défaut, Supabase envoie un lien de confirmation avant d'autoriser la première connexion.

- **Tu veux ce lien** (recommandé si l'app sera publique) : ne touche à rien. À la création du compte, l'application affiche « Ouvre le lien reçu par e-mail, puis connecte-toi ».
- **Tu veux entrer tout de suite** (pratique si c'est ton usage personnel) : **Authentication → Sign In / Providers → Email** et désactive *Confirm email*.

## 4. Déployer

Mets à la racine de ton dossier :

```
index.html
vercel.json
```

Puis Vercel → *Add New Project* → importe le dossier ou le dépôt Git.

- Framework Preset : **Other**
- Build Command, Install Command, Output Directory : **vides**
- Root Directory : vide, ou le dossier contenant `index.html`

Déploie. Crée ton compte depuis l'application, et tes tâches sont dans ta base.

---

## Comment fonctionne l'enregistrement

Chaque modification est écrite **immédiatement dans le cache de l'appareil**, puis envoyée à la base sept dixièmes de seconde plus tard. Conséquence : l'interface ne fige jamais en attendant le réseau, et si la connexion tombe, tu vois passer « Hors ligne — gardé sur l'appareil » et rien n'est perdu.

Deux exceptions volontaires :

- **Ajouter une tâche** n'écrit rien avant que tu appuies sur *Ajouter la tâche*. Tant que tu n'as pas confirmé, la capsule n'existe pas — ni à l'écran, ni en base. Fermer la fiche l'abandonne.
- **Enregistrer** et **Supprimer** poussent vers la base sans attendre le délai.

## Ajouter l'app à ton écran d'accueil

Sur iPhone, ouvre ton URL dans Safari → bouton Partager → *Sur l'écran d'accueil*. Elle s'ouvrira en plein écran, sans barre de navigateur. La session reste ouverte, tu n'auras pas à te reconnecter.
