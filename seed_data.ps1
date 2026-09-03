﻿﻿$ErrorActionPreference = "Stop"

Write-Host "Authentification en tant que professeur..."
$login = Invoke-RestMethod -Uri "http://localhost:5008/api/auth/login" -Method Post -ContentType "application/json" -Body '{"email":"prof@ensat.ma","motDePasse":"admin123"}'
$token = $login.token
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json; charset=utf-8" }

Write-Host "Nettoyage du tissu de test..."
$existingTissus = Invoke-RestMethod -Uri "http://localhost:5008/api/tissus" -Headers $headers -Method Get
$dummy = $existingTissus | Where-Object { $_.codeLabelIa -eq "test_label" }
if ($dummy) {
    try {
        Invoke-RestMethod -Uri "http://localhost:5008/api/tissus/$($dummy.id)" -Headers $headers -Method Delete
        Write-Host "Tissu test supprime."
    } catch {
        Write-Host "Impossible de supprimer le tissu test: $_"
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. ORGANES
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`nCreation / recuperation des Organes..."
$organesList = @(
    "Rein (Tubules & Nephrons)",
    "Intestin grele",
    "Peau (Epiderme & Derme)",
    "Oesophage",
    "Tendon & Ligament",
    "Hypoderme (Sous-cutane)",
    "Muscle squelettique (Biceps)",
    "Diaphragme & Langue",
    "Paroi digestive (Musculeuse)",
    "Arteres & Vaisseaux sanguins",
    "Trachee & Anneaux bronchiques",
    "Cartilage articulaire",
    "Os long (Femur / Diaphyse)"
)

$existingOrganes = Invoke-RestMethod -Uri "http://localhost:5008/api/organes" -Headers $headers -Method Get
$organeMap = @{}
foreach ($o in $existingOrganes) {
    $organeMap[$o.nom] = $o.id
}

foreach ($nom in $organesList) {
    if (-not $organeMap.ContainsKey($nom)) {
        $body = @{ nom = $nom } | ConvertTo-Json
        $created = Invoke-RestMethod -Uri "http://localhost:5008/api/organes" -Headers $headers -Method Post -Body $body
        $organeMap[$nom] = $created.id
        Write-Host "  Organe cree: $nom ($($created.id))"
    } else {
        Write-Host "  Organe deja existant: $nom"
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. DEFINITION DES 9 TISSUS ET DE LEURS 7 QUESTIONS QCM CHACUN
# ─────────────────────────────────────────────────────────────────────────────
$dataset = @(
    @{
        Code = "ADI"
        Nom = "Tissu adipeux"
        Description = "Le tissu adipeux est un tissu conjonctif lâche composé principalement d'adipocytes, spécialisé dans le stockage d'énergie sous forme de lipides, l'isolation thermique et la protection mécanique."
        Fonctions = "Stockage d'énergie (triglycérides), isolation thermique, protection mécanique, sécrétion d'adipokines (fonction endocrine)."
        Organes = @("Hypoderme (Sous-cutane)")
        Questions = @(
            @{ Texte = "Quelle est la principale cellule fonctionnelle du tissu adipeux blanc ?"; Choix = @( @{ Texte = "L'adipocyte uniloculaire"; EstCorrect = $true }, @{ Texte = "Le fibroblaste"; EstCorrect = $false }, @{ Texte = "Le macrophage"; EstCorrect = $false }, @{ Texte = "L'adipocyte multiloculaire"; EstCorrect = $false } ) },
            @{ Texte = "Sous quelle forme les lipides sont-ils principalement stockés dans l'adipocyte blanc ?"; Choix = @( @{ Texte = "Une grande vacuole lipidique unique"; EstCorrect = $true }, @{ Texte = "De multiples petites gouttelettes lipidiques"; EstCorrect = $false }, @{ Texte = "Des granules de glycogène"; EstCorrect = $false }, @{ Texte = "Des vésicules de sécrétion"; EstCorrect = $false } ) },
            @{ Texte = "Quelle fonction endocrine majeure est associée au tissu adipeux ?"; Choix = @( @{ Texte = "Sécrétion de leptine"; EstCorrect = $true }, @{ Texte = "Sécrétion d'insuline"; EstCorrect = $false }, @{ Texte = "Sécrétion de glucagon"; EstCorrect = $false }, @{ Texte = "Sécrétion de thyroxine"; EstCorrect = $false } ) },
            @{ Texte = "Dans quelle couche tissulaire trouve-t-on le plus de tissu adipeux sous la peau ?"; Choix = @( @{ Texte = "L'hypoderme"; EstCorrect = $true }, @{ Texte = "L'épiderme"; EstCorrect = $false }, @{ Texte = "Le derme papillaire"; EstCorrect = $false }, @{ Texte = "La membrane basale"; EstCorrect = $false } ) },
            @{ Texte = "Quelle est la coloration courante pour mettre en évidence les lipides des adipocytes sur des coupes congelées ?"; Choix = @( @{ Texte = "L'Oil Red O ou le Noir Soudan"; EstCorrect = $true }, @{ Texte = "L'Hématoxyline et Eosine"; EstCorrect = $false }, @{ Texte = "Le Trichrome de Masson"; EstCorrect = $false }, @{ Texte = "La coloration de PAS"; EstCorrect = $false } ) },
            @{ Texte = "Quel rôle mécanique joue le tissu adipeux dans des zones comme la plante des pieds ?"; Choix = @( @{ Texte = "Amortisseur de chocs"; EstCorrect = $true }, @{ Texte = "Rigidité structurelle"; EstCorrect = $false }, @{ Texte = "Contraction musculaire"; EstCorrect = $false }, @{ Texte = "Transmission nerveuse"; EstCorrect = $false } ) },
            @{ Texte = "Comment se caractérise le noyau d'un adipocyte blanc mature ?"; Choix = @( @{ Texte = "Aplati et repoussé en périphérie contre la membrane plasmique"; EstCorrect = $true }, @{ Texte = "Central, gros et sphérique"; EstCorrect = $false }, @{ Texte = "Multilobé et central"; EstCorrect = $false }, @{ Texte = "Absent (cellule anucléée)"; EstCorrect = $false } ) }
        )
    },
    @{
        Code = "BACK"
        Nom = "Fond de lame / hors tissu"
        Description = "Cette catégorie représente le fond de la lame (verre) ou l'espace vide autour des échantillons tissulaires. Il ne s'agit pas d'un tissu biologique."
        Fonctions = "Aucune fonction biologique. Espace vide ou artefact technique."
        Organes = @()
        Questions = @()
    },
    @{
        Code = "DEB"
        Nom = "Débris cellulaires"
        Description = "Débris cellulaires, restes nécrotiques ou fragments biologiques non structurés. Ne correspond pas à un tissu sain et organisé, souvent issu de mort cellulaire ou d'artefacts de préparation."
        Fonctions = "Aucune fonction biologique organisée (restes d'apoptose, nécrose ou préparation de lame)."
        Organes = @()
        Questions = @()
    },
    @{
        Code = "LYM"
        Nom = "Lymphocytes"
        Description = "Cellules immunitaires agranulaires, avec un noyau dense et volumineux et un cytoplasme très fin. Ils sont souvent observés en amas dans les zones d'inflammation ou le tissu lymphoïde."
        Fonctions = "Défense immunitaire spécifique (cellulaire ou humorale), surveillance tissulaire."
        Organes = @("Intestin grele")
        Questions = @(
            @{ Texte = "Quelle est la morphologie typique d'un lymphocyte au repos en microscopie optique ?"; Choix = @( @{ Texte = "Noyau dense, rond occupant presque toute la cellule, fine couronne de cytoplasme"; EstCorrect = $true }, @{ Texte = "Noyau polylobé avec granulations cytoplasmiques"; EstCorrect = $false }, @{ Texte = "Cellule fusiforme avec de longs prolongements"; EstCorrect = $false }, @{ Texte = "Cellule géante multinucléée"; EstCorrect = $false } ) },
            @{ Texte = "Quel est le rôle principal des lymphocytes B ?"; Choix = @( @{ Texte = "Production d'anticorps (après différenciation en plasmocytes)"; EstCorrect = $true }, @{ Texte = "Phagocytose des débris"; EstCorrect = $false }, @{ Texte = "Sécrétion de collagène"; EstCorrect = $false }, @{ Texte = "Transport de l'oxygène"; EstCorrect = $false } ) },
            @{ Texte = "Où trouve-t-on de grandes accumulations de lymphocytes dans le tube digestif ?"; Choix = @( @{ Texte = "Dans le tissu lymphoïde associé aux muqueuses (MALT, ex: Plaques de Peyer)"; EstCorrect = $true }, @{ Texte = "Dans l'épithélium de surface de l'estomac"; EstCorrect = $false }, @{ Texte = "Dans la musculeuse lisse de l'oesophage"; EstCorrect = $false }, @{ Texte = "Dans la lumière de la vésicule biliaire"; EstCorrect = $false } ) }
        )
    },
    @{
        Code = "MUC"
        Nom = "Mucus"
        Description = "Sécrétion extracellulaire visqueuse riche en glycoprotéines (mucines), produite par les cellules caliciformes ou les glandes muqueuses pour protéger ou lubrifier les épithéliums."
        Fonctions = "Lubrification, protection contre les agents chimiques/mécaniques, piégeage des pathogènes."
        Organes = @("Intestin grele", "Trachee & Anneaux bronchiques")
        Questions = @(
            @{ Texte = "Quelle cellule épithéliale isolée est spécialisée dans la production de mucus dans l'intestin et les voies respiratoires ?"; Choix = @( @{ Texte = "La cellule caliciforme"; EstCorrect = $true }, @{ Texte = "L'entérocyte"; EstCorrect = $false }, @{ Texte = "Le pneumocyte de type 1"; EstCorrect = $false }, @{ Texte = "Le lymphocyte T"; EstCorrect = $false } ) },
            @{ Texte = "Quelle coloration spéciale est souvent utilisée pour bien mettre en évidence le mucus (glucides) en microscopie ?"; Choix = @( @{ Texte = "La coloration de PAS (Periodic Acid-Schiff) ou Bleu Alcian"; EstCorrect = $true }, @{ Texte = "L'imprégnation argentique"; EstCorrect = $false }, @{ Texte = "La coloration à l'orcéine"; EstCorrect = $false }, @{ Texte = "Le Rouge Congo"; EstCorrect = $false } ) },
            @{ Texte = "Quel est le rôle principal du mucus dans les voies respiratoires ?"; Choix = @( @{ Texte = "Piéger les poussières et les micro-organismes avant qu'ils n'atteignent les alvéoles"; EstCorrect = $true }, @{ Texte = "Faciliter les échanges gazeux d'oxygène"; EstCorrect = $false }, @{ Texte = "Capter l'azote de l'air"; EstCorrect = $false }, @{ Texte = "Digérer les particules inhalées par action acide"; EstCorrect = $false } ) }
        )
    },
    @{
        Code = "MUS"
        Nom = "Muscle lisse"
        Description = "Tissu musculaire non strié composé de cellules fusiformes (léiomyocytes) à contraction involontaire, lente et soutenue, tapissant les parois des viscères et vaisseaux."
        Fonctions = "Péristaltisme, régulation du tonus vasculaire, contraction des organes creux."
        Organes = @("Paroi digestive (Musculeuse)", "Arteres & Vaisseaux sanguins", "Intestin grele")
        Questions = @(
            @{ Texte = "Comment se présente une cellule de muscle lisse en microscopie optique longitudinale ?"; Choix = @( @{ Texte = "Cellule fusiforme avec un noyau unique, central et de forme allongée"; EstCorrect = $true }, @{ Texte = "Cellule cylindrique multinucléée avec des stries transversales"; EstCorrect = $false }, @{ Texte = "Cellule ramifiée avec un noyau central et des disques intercalaires"; EstCorrect = $false }, @{ Texte = "Cellule pavimenteuse avec un noyau aplati"; EstCorrect = $false } ) },
            @{ Texte = "Par quel système la contraction du muscle lisse est-elle régulée ?"; Choix = @( @{ Texte = "Le système nerveux autonome (involontaire)"; EstCorrect = $true }, @{ Texte = "Le système nerveux somatique (volontaire)"; EstCorrect = $false }, @{ Texte = "Uniquement par la volonté consciente"; EstCorrect = $false }, @{ Texte = "Exclusivement par des hormones thyroïdiennes"; EstCorrect = $false } ) },
            @{ Texte = "Où trouve-t-on typiquement d'épaisses couches de muscle lisse formant une musculeuse ?"; Choix = @( @{ Texte = "Dans la paroi du tube digestif (intestin, estomac)"; EstCorrect = $true }, @{ Texte = "Dans le myocarde (coeur)"; EstCorrect = $false }, @{ Texte = "Attaché aux os longs (biceps, triceps)"; EstCorrect = $false }, @{ Texte = "Dans le parenchyme rénal"; EstCorrect = $false } ) }
        )
    },
    @{
        Code = "NORM"
        Nom = "Muqueuse colique normale"
        Description = "Tissu tapissant la lumière du côlon, formé d'un épithélium prismatique simple invaginé en cryptes de Lieberkühn, riche en cellules caliciformes et reposant sur un chorion."
        Fonctions = "Absorption d'eau et d'électrolytes, sécrétion massive de mucus pour la lubrification des fèces."
        Organes = @("Intestin grele")
        Questions = @(
            @{ Texte = "Quelle structure glandulaire droite est caractéristique de la muqueuse colique saine ?"; Choix = @( @{ Texte = "Les cryptes de Lieberkühn"; EstCorrect = $true }, @{ Texte = "Les glandes de Brunner"; EstCorrect = $false }, @{ Texte = "Les glandes gastriques"; EstCorrect = $false }, @{ Texte = "Les follicules thyroïdiens"; EstCorrect = $false } ) },
            @{ Texte = "La muqueuse colique normale est particulièrement riche en quel type de cellules ?"; Choix = @( @{ Texte = "Les cellules caliciformes à mucus"; EstCorrect = $true }, @{ Texte = "Les cellules pariétales sécrétrices d'acide"; EstCorrect = $false }, @{ Texte = "Les hépatocytes"; EstCorrect = $false }, @{ Texte = "Les pneumocytes de type II"; EstCorrect = $false } ) },
            @{ Texte = "Contrairement à l'intestin grêle, quelle structure est absente de la surface de la muqueuse colique ?"; Choix = @( @{ Texte = "Les villosités intestinales"; EstCorrect = $true }, @{ Texte = "Les cryptes glandulaires"; EstCorrect = $false }, @{ Texte = "L'épithélium de revêtement"; EstCorrect = $false }, @{ Texte = "La musculaire muqueuse"; EstCorrect = $false } ) }
        )
    },
    @{
        Code = "STR"
        Nom = "Stroma associé au cancer"
        Description = "Tissu conjonctif réactif entourant les cellules tumorales, souvent caractérisé par une fibrose importante (desmoplasie), de nouveaux vaisseaux et une infiltration inflammatoire."
        Fonctions = "Soutien architectural de la tumeur, facilitation de la croissance tumorale, angiogenèse et modulation de la réponse immunitaire."
        Organes = @("Paroi digestive (Musculeuse)")
        Questions = @(
            @{ Texte = "Qu'est-ce que le stroma dans un tissu tumoral ?"; Choix = @( @{ Texte = "Le tissu de soutien, conjonctif et vasculaire, autour des cellules cancéreuses"; EstCorrect = $true }, @{ Texte = "Le centre nécrotique de la tumeur"; EstCorrect = $false }, @{ Texte = "L'ensemble des cellules malignes proliférantes"; EstCorrect = $false }, @{ Texte = "La capsule fibreuse saine repoussant la tumeur"; EstCorrect = $false } ) },
            @{ Texte = "Comment appelle-t-on la réaction fibreuse dense souvent observée dans le stroma des carcinomes ?"; Choix = @( @{ Texte = "La desmoplasie"; EstCorrect = $true }, @{ Texte = "L'hyperplasie lymphoïde"; EstCorrect = $false }, @{ Texte = "La métaplasie malpighienne"; EstCorrect = $false }, @{ Texte = "La kératinisation"; EstCorrect = $false } ) },
            @{ Texte = "Quelle cellule est le principal acteur de la production de collagène dans ce stroma tumoral réactif ?"; Choix = @( @{ Texte = "Le fibroblaste (ou myofibroblaste) associé au cancer"; EstCorrect = $true }, @{ Texte = "L'ostéoblaste"; EstCorrect = $false }, @{ Texte = "Le chondrocyte"; EstCorrect = $false }, @{ Texte = "L'adipocyte"; EstCorrect = $false } ) }
        )
    },
    @{
        Code = "TUM"
        Nom = "Épithélium d'adénocarcinome colorectal"
        Description = "Cellules épithéliales malignes du côlon formant des structures glandulaires anormales, désorganisées, avec atypies nucléaires et perte de la polarité basale."
        Fonctions = "Prolifération anarchique, invasion des tissus sous-jacents, destruction de l'architecture normale."
        Organes = @("Intestin grele")
        Questions = @(
            @{ Texte = "Qu'est-ce qui caractérise histologiquement un adénocarcinome par rapport à un tissu sain ?"; Choix = @( @{ Texte = "Une prolifération de cellules épithéliales malignes formant des glandes anarchiques, avec atypies cytonucléaires"; EstCorrect = $true }, @{ Texte = "Une augmentation régulière du nombre de cellules strictement normales"; EstCorrect = $false }, @{ Texte = "La simple présence de cellules inflammatoires"; EstCorrect = $false }, @{ Texte = "La disparition complète de tout tissu épithélial"; EstCorrect = $false } ) },
            @{ Texte = "Lorsqu'on observe l'épithélium tumoral, que signifie la 'perte de polarité' ?"; Choix = @( @{ Texte = "Les noyaux ne sont plus alignés à la base et s'organisent de façon anarchique dans la cellule"; EstCorrect = $true }, @{ Texte = "Les cellules ont perdu leur charge électrique"; EstCorrect = $false }, @{ Texte = "La tumeur ne croît que dans un seul sens"; EstCorrect = $false }, @{ Texte = "Les cellules épithéliales deviennent sphériques"; EstCorrect = $false } ) },
            @{ Texte = "Quelle caractéristique nucléaire est typique des cellules épithéliales de l'adénocarcinome colorectal ?"; Choix = @( @{ Texte = "Hyperchromasie (noyaux très sombres), augmentation de la taille et nucléoles proéminents"; EstCorrect = $true }, @{ Texte = "Noyaux petits, clairs et très réguliers"; EstCorrect = $false }, @{ Texte = "Absence de noyau (anoxie)"; EstCorrect = $false }, @{ Texte = "Noyaux refoulés et aplatis contre la membrane en périphérie"; EstCorrect = $false } ) }
        )
    }
)

# ─────────────────────────────────────────────────────────────────────────────
# 3. CREATION / MISE A JOUR DES TISSUS & DES 7 QUESTIONS CHACUN
# ─────────────────────────────────────────────────────────────────────────────
$allTissus = Invoke-RestMethod -Uri "http://localhost:5008/api/tissus" -Headers $headers -Method Get
$tissuMap = @{}
foreach ($t in $allTissus) {
    $tissuMap[$t.codeLabelIa] = $t
}

$totalQuestionsCreated = 0

foreach ($item in $dataset) {
    Write-Host "`nTraitement de $($item.Code) : $($item.Nom)..."
    
    # Trouver les ID d'organes associés
    $targetOrganeIds = @()
    foreach ($orgNom in $item.Organes) {
        if ($organeMap.ContainsKey($orgNom)) {
            $targetOrganeIds += $organeMap[$orgNom]
        }
    }

    $tissuId = $null

    if ($tissuMap.ContainsKey($item.Code)) {
        $tissuId = $tissuMap[$item.Code].id
        Write-Host "  Tissu deja existant avec ID: $tissuId"
        # Optionnel: Mettre a jour les donnees
        try {
            $updateBody = @{
                nom = $item.Nom
                description = $item.Description
                fonctions = $item.Fonctions
                codeLabelIa = $item.Code
                organeIds = @($targetOrganeIds)
            } | ConvertTo-Json
            Invoke-RestMethod -Uri "http://localhost:5008/api/tissus/$tissuId" -Headers $headers -Method Put -Body $updateBody
            Write-Host "  Tissu mis a jour."
        } catch {
            Write-Host "  Mise a jour non requise ou ignoree: $_"
        }
    } else {
        $createBody = @{
            nom = $item.Nom
            description = $item.Description
            fonctions = $item.Fonctions
            codeLabelIa = $item.Code
            organeIds = @($targetOrganeIds)
        } | ConvertTo-Json
                Write-Host "DUMP JSON:"
        Write-Host $createBody
        try {
            $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($createBody)
            $created = Invoke-RestMethod -Uri "http://localhost:5008/api/tissus" -Headers $headers -Method Post -Body $bodyBytes
        } catch {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            Write-Host "Error body: $($reader.ReadToEnd())"
            throw $_
        }
        $tissuId = $created.id
        Write-Host "  Tissu cree avec succes! ID: $tissuId"
    }

    # Recuperer les questions existantes pour ce tissu
    $existingQuestions = Invoke-RestMethod -Uri "http://localhost:5008/api/questions/tissu/$tissuId" -Headers $headers -Method Get
    Write-Host "  Ce tissu possede actuellement $($existingQuestions.Count) question(s)."

    # Nettoyer si besoin pour avoir exactement 7 questions pedagogiques propres
    if ($existingQuestions.Count -gt 0 -and $existingQuestions.Count -ne $item.Questions.Count) {
        Write-Host "  Nettoyage des questions precedentes pour inserer les questions officielles..."
        foreach ($q in $existingQuestions) {
            try {
                Invoke-RestMethod -Uri "http://localhost:5008/api/questions/$($q.id)" -Headers $headers -Method Delete
            } catch {}
        }
        $existingQuestions = @()
    }

    if ($existingQuestions.Count -eq 0) {
        Write-Host "  Insertion des questions QCM..."
        foreach ($qData in $item.Questions) {
            $qBody = @{
                tissuId = $tissuId
                texte = $qData.Texte
                choix = $qData.Choix
            } | ConvertTo-Json -Depth 5

            $resQ = Invoke-RestMethod -Uri "http://localhost:5008/api/questions" -Headers $headers -Method Post -Body $qBody
            $totalQuestionsCreated++
        }
        Write-Host "  -> $($item.Questions.Count) questions inserees avec succes!"
    } else {
        Write-Host "  -> Le tissu possede deja ses questions valides."
    }
}

Write-Host "`n========================================================"
Write-Host "INITIALISATION TERMINEE AVEC SUCCES !"
Write-Host "========================================================"
Write-Host "Total questions creees : $totalQuestionsCreated"
