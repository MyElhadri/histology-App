$ErrorActionPreference = "Stop"

Write-Host "Authentification en tant que professeur..."
$login = Invoke-RestMethod -Uri "http://localhost:5008/api/auth/login" -Method Post -ContentType "application/json" -Body '{"email":"prof@ensat.ma","motDePasse":"admin123"}'
$token = $login.token
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }

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
        Code = "classe_00"
        Nom = "Tissu Epithelial Simple"
        Description = "Epithelium unistratifie forme d'une couche unique de cellules (cubiques ou prismatiques) reposant sur une lame basale bien individualisee."
        Fonctions = "Absorption selective des nutriments, secretion enzymatique ou muqueuse, et filtration liquidienne."
        Organes = @("Rein (Tubules & Nephrons)", "Intestin grele")
        Questions = @(
            @{
                Texte = "Quel est le trait distinctif morphologique majeur d'un epithelium simple ?"
                Choix = @(
                    @{ Texte = "Une seule assise de cellules reposant directement sur la membrane basale"; EstCorrect = $true },
                    @{ Texte = "Plusieurs couches superposees avec desquamation superficielle"; EstCorrect = $false },
                    @{ Texte = "Une matrice extracellulaire tres abondante et vascularisee"; EstCorrect = $false },
                    @{ Texte = "Une absence totale de polarite cellulaire apico-basale"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Au niveau des enterocytes de l'intestin grele, quelle specialisation apicale optimise l'absorption ?"
                Choix = @(
                    @{ Texte = "Les microvillosites sous forme de plateau strie"; EstCorrect = $true },
                    @{ Texte = "Les cils vibratiles mobiles"; EstCorrect = $false },
                    @{ Texte = "Une epaisse couche de keratine anucleee"; EstCorrect = $false },
                    @{ Texte = "Des flagelles contractiles"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel type cellulaire glandulaire intercale observe-t-on frequemment dans l'epithelium prismatique simple intestinal ?"
                Choix = @(
                    @{ Texte = "La cellule caliciforme secretant du mucus"; EstCorrect = $true },
                    @{ Texte = "L'adipocyte uniloculaire"; EstCorrect = $false },
                    @{ Texte = "Le fibroblaste quiescent"; EstCorrect = $false },
                    @{ Texte = "L'osteoclaste multinuclee"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment les epitheliums simples assurent-ils leur nutrition en l'absence de vascularisation propre ?"
                Choix = @(
                    @{ Texte = "Par diffusion passive et transport a partir des capillaires du chorion sous-jacent"; EstCorrect = $true },
                    @{ Texte = "Par un reseau de capillaires sanguins intra-epitheliaux"; EstCorrect = $false },
                    @{ Texte = "Par autophagie exclusive des cellules basales"; EstCorrect = $false },
                    @{ Texte = "Par des canaux lymphatiques perforants"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Dans les tubules contournes proximaux du rein, l'epithelium est de quel type ?"
                Choix = @(
                    @{ Texte = "Epithelium cubique simple a bordure en brosse"; EstCorrect = $true },
                    @{ Texte = "Epithelium pavimenteux stratifie keratine"; EstCorrect = $false },
                    @{ Texte = "Tissu conjonctif dense regulier"; EstCorrect = $false },
                    @{ Texte = "Epithelium transitionnel urothelial"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle structure jonctionnelle assure l'etancheite et empeche le passage paracellulaire dans l'epithelium simple ?"
                Choix = @(
                    @{ Texte = "La jonction serree (zonula occludens)"; EstCorrect = $true },
                    @{ Texte = "La jonction communicante (gap junction)"; EstCorrect = $false },
                    @{ Texte = "L'hemidesmosome basal"; EstCorrect = $false },
                    @{ Texte = "Le complexe pericentriolaire"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel pole de la cellule epitheliale est en contact direct avec la lame basale ?"
                Choix = @(
                    @{ Texte = "Le pole basal"; EstCorrect = $true },
                    @{ Texte = "Le pole apical"; EstCorrect = $false },
                    @{ Texte = "La face laterale intercellulaire"; EstCorrect = $false },
                    @{ Texte = "Le domaine ciliaire"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_01"
        Nom = "Tissu Conjonctif Lache (Stroma)"
        Description = "Tissu de soutien ubiquitaire comportant une proportion equilibree de cellules, de fibres de collagene minces et de substance fondamentale riche en eau."
        Fonctions = "Support mecanique souple, nutrition des epitheliums, vehicule des cellules immunitaires et cicatrisation."
        Organes = @("Peau (Epiderme & Derme)", "Paroi digestive (Musculeuse)")
        Questions = @(
            @{
                Texte = "Quelle cellule est la principale responsable de la synthese de la matrice extracellulaire dans le tissu conjonctif lache ?"
                Choix = @(
                    @{ Texte = "Le fibroblaste"; EstCorrect = $true },
                    @{ Texte = "Le keratinocyte"; EstCorrect = $false },
                    @{ Texte = "Le chondrocyte"; EstCorrect = $false },
                    @{ Texte = "L'enterocyte"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle est la principale caracteristique de la matrice extracellulaire du tissu conjonctif lache ?"
                Choix = @(
                    @{ Texte = "Elle est riche en substance fondamentale hydra-amorphe avec des fibres espacees"; EstCorrect = $true },
                    @{ Texte = "Elle est solidement calcifiee et sans eau"; EstCorrect = $false },
                    @{ Texte = "Elle est entierement constituee de fibres de collagene tassees sans substance fondamentale"; EstCorrect = $false },
                    @{ Texte = "Elle est absente, les cellules etant jointives sans matrice"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel composant moleculaire confere a la substance fondamentale sa capacite elevee de retention d'eau ?"
                Choix = @(
                    @{ Texte = "Les glycosaminoglycanes (GAGs) et proteoglycanes"; EstCorrect = $true },
                    @{ Texte = "Les molecules d'actine et de myosine"; EstCorrect = $false },
                    @{ Texte = "L'hydroxyapatite de calcium"; EstCorrect = $false },
                    @{ Texte = "La keratine filamenteuse"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel role immunitaire joue le chorion constitue de tissu conjonctif lache ?"
                Choix = @(
                    @{ Texte = "Il abrite des macrophages, plasmocytes et mastocytes pour la defense locale"; EstCorrect = $true },
                    @{ Texte = "Il secrete l'acide gastrique chlorhydrique"; EstCorrect = $false },
                    @{ Texte = "Il genere les potentiels d'action moteurs"; EstCorrect = $false },
                    @{ Texte = "Il synthetise exclusivement les hormones thyroïdiennes"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment appelle-t-on le tissu conjonctif lache soutenant les epitheliums des muqueuses digestives ?"
                Choix = @(
                    @{ Texte = "Le chorion ou lamina propria"; EstCorrect = $true },
                    @{ Texte = "Le perioste"; EstCorrect = $false },
                    @{ Texte = "Le perichondre"; EstCorrect = $false },
                    @{ Texte = "L'epinevre"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelles fibres extracellulaires conferent l'elasticite et la flexibilite au tissu conjonctif lache ?"
                Choix = @(
                    @{ Texte = "Les fibres elastiques formees d'elastine"; EstCorrect = $true },
                    @{ Texte = "Les tonofilaments de keratine"; EstCorrect = $false },
                    @{ Texte = "Les myofibrilles d'actine"; EstCorrect = $false },
                    @{ Texte = "Les trabecules osteoïdes"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle est l'evolution du fibroblaste lorsqu'il devient moins actif metaboliquement ?"
                Choix = @(
                    @{ Texte = "Il se transforme en fibrocyte quiescent"; EstCorrect = $true },
                    @{ Texte = "Il mute directement en ostéoblaste"; EstCorrect = $false },
                    @{ Texte = "Il fusionne pour creer une fibre musculaire"; EstCorrect = $false },
                    @{ Texte = "Il se detache pour devenir une hematie"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_02"
        Nom = "Tissu Conjonctif Dense"
        Description = "Tissu caracterise par une abondance massive de volumineux faisceaux de collagene compacts avec peu de cellules et peu de substance fondamentale."
        Fonctions = "Resistance maximale aux fortes contraintes mecaniques et forces de traction multidirectionnelles ou axiales."
        Organes = @("Tendon & Ligament", "Peau (Epiderme & Derme)")
        Questions = @(
            @{
                Texte = "Dans un tendon, comment sont orientees les fibres de collagene de type I ?"
                Choix = @(
                    @{ Texte = "Paralleles et serrees le long de l'axe de traction (tissu dense regulier orienté)"; EstCorrect = $true },
                    @{ Texte = "Enchevêtrees en tout sens de façon desordonnee"; EstCorrect = $false },
                    @{ Texte = "Discontinuees sous forme de reseau spongieux"; EstCorrect = $false },
                    @{ Texte = "Circulaires concentriques autour des vaisseaux"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel type de collagene predomine largement dans le tissu conjonctif dense des tendons et ligaments ?"
                Choix = @(
                    @{ Texte = "Collagene de type I"; EstCorrect = $true },
                    @{ Texte = "Collagene de type II"; EstCorrect = $false },
                    @{ Texte = "Collagene de type IV"; EstCorrect = $false },
                    @{ Texte = "Collagene de type IX"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Pourquoi les lesions tendineuses cicatrisent-elles generalement tres lentement ?"
                Choix = @(
                    @{ Texte = "A cause de la faible vascularisation propre et du métabolisme cellulaire reduit"; EstCorrect = $true },
                    @{ Texte = "En raison d'un excès incontrôlé de flux sanguin"; EstCorrect = $false },
                    @{ Texte = "Parce que les cellules sont totipotentes et prolifèrent trop vite"; EstCorrect = $false },
                    @{ Texte = "A cause d'une destruction enzymatique automatique de l'actine"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle est la denomination des fibroblastes specifiques loges et allonges entre les faisceaux d'un tendon ?"
                Choix = @(
                    @{ Texte = "Les tenocytes"; EstCorrect = $true },
                    @{ Texte = "Les chondrocytes"; EstCorrect = $false },
                    @{ Texte = "Les pericytes"; EstCorrect = $false },
                    @{ Texte = "Les cellules de Schwann"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Le derme reticulaire profond de la peau est un exemple de :"
                Choix = @(
                    @{ Texte = "Tissu conjonctif dense non orienté (ou semi-orienté)"; EstCorrect = $true },
                    @{ Texte = "Tissu conjonctif dense régulier parfait"; EstCorrect = $false },
                    @{ Texte = "Epithelium stratifie cylindrique"; EstCorrect = $false },
                    @{ Texte = "Tissu cartilagineux elastique"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Par quel type de gaine de tissu conjonctif lache vascularise le tendon est-il entoure ?"
                Choix = @(
                    @{ Texte = "L'epitendon (ou peritendon)"; EstCorrect = $true },
                    @{ Texte = "L'endoste"; EstCorrect = $false },
                    @{ Texte = "Le sarcolemme"; EstCorrect = $false },
                    @{ Texte = "La capsule articulaire synoviale"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Sous coloration a l'Hematoxyline-Eosine, quelle est la teinte caracteristique des faisceaux de collagene ?"
                Choix = @(
                    @{ Texte = "Rose intense / Eosinophile acidophile"; EstCorrect = $true },
                    @{ Texte = "Bleu foncé / Basophile intense"; EstCorrect = $false },
                    @{ Texte = "Transparent incolore comme une vacuole"; EstCorrect = $false },
                    @{ Texte = "Jaune fluorescent brillant"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_03"
        Nom = "Tissu Adipeux (Graisse Blanche)"
        Description = "Tissu conjonctif specialise constitue de volumineuses cellules arrondies remplies d'une vacuole lipidique unique refoulant le noyau aplati en peripherie."
        Fonctions = "Reserve energetique majeure sous forme de triglycerides, isolation thermique corporelle et protection mecanique contre les chocs."
        Organes = @("Hypoderme (Sous-cutane)", "Peau (Epiderme & Derme)")
        Questions = @(
            @{
                Texte = "Quelle est l'apparence morphologique classique de l'adipocyte blanc sur une coupe histologique standard apres dissolution des graisses ?"
                Choix = @(
                    @{ Texte = "Aspect en 'bague a chaton' avec grand espace clair optiquement vide et noyau aplati en peripherie"; EstCorrect = $true },
                    @{ Texte = "Cellule fusiforme sombre aux extremites effilees et noyau central"; EstCorrect = $false },
                    @{ Texte = "Cellule ramifiee aux prolongements dendritiques multiples"; EstCorrect = $false },
                    @{ Texte = "Structure cylindrique multinucleee a striations transversales"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel solvant organique utilise lors de la preparation histologique paraffine dissout les lipides intracellulaires ?"
                Choix = @(
                    @{ Texte = "Le xylene (ou solvant de substitution) et les alcools"; EstCorrect = $true },
                    @{ Texte = "L'eau distillee pure tamponnee"; EstCorrect = $false },
                    @{ Texte = "L'hematoxyline ferrique"; EstCorrect = $false },
                    @{ Texte = "L'azote liquide sous pression"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Sous quelle forme moleculaire les lipides sont-ils principalement stockes dans l'adipocyte blanc ?"
                Choix = @(
                    @{ Texte = "Triglycerides (triacylglycerols)"; EstCorrect = $true },
                    @{ Texte = "Glycogene ramifie"; EstCorrect = $false },
                    @{ Texte = "Acides amines libres"; EstCorrect = $false },
                    @{ Texte = "Cristaux d'urate"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle hormone endocrine majeure est produite par le tissu adipeux pour reguler la satiete ?"
                Choix = @(
                    @{ Texte = "La leptine"; EstCorrect = $true },
                    @{ Texte = "L'insuline"; EstCorrect = $false },
                    @{ Texte = "Le glucagon"; EstCorrect = $false },
                    @{ Texte = "La thyroxine"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle coloration histochimique specifique sur coupes en congelation permet de reveler les lipides neutres ?"
                Choix = @(
                    @{ Texte = "Oil Red O ou Rouge Soudan (Sudan III/IV)"; EstCorrect = $true },
                    @{ Texte = "Bleu de Coomassie"; EstCorrect = $false },
                    @{ Texte = "Coloration de Gram"; EstCorrect = $false },
                    @{ Texte = "Coloration de Ziehl-Neelsen"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment est vascularise le tissu adipeux blanc ?"
                Choix = @(
                    @{ Texte = "Tres richement vascularise par un reseau dense de capillaires au contact de chaque adipocyte"; EstCorrect = $true },
                    @{ Texte = "Totalement avasculaire, la nutrition se faisant uniquement par l'air ambiant"; EstCorrect = $false },
                    @{ Texte = "Traverse par une unique veine centrale sans capillaires"; EstCorrect = $false },
                    @{ Texte = "Dote de sinusoides caverneux sans paroi propre"; EstCorrect = $false }
                )
            },
            @{
                Texte = "En quoi le tissu adipeux brun se distingue-t-il histologiquement du tissu adipeux blanc ?"
                Choix = @(
                    @{ Texte = "Les adipocytes bruns sont multiloculaires, riches en mitochondries et thermogeniques"; EstCorrect = $true },
                    @{ Texte = "Les adipocytes bruns ne contiennent aucun lipide"; EstCorrect = $false },
                    @{ Texte = "Les adipocytes bruns sont depourvus de noyaux"; EstCorrect = $false },
                    @{ Texte = "Le tissu brun est situe exclusivement dans le cartilage articulaire"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_04"
        Nom = "Epithelium Stratifie Pavimenteux"
        Description = "Epithelium compose de nombreuses assises cellulaires superposees dont les cellules des couches superficielles sont aplaties en squames."
        Fonctions = "Protection mecanique majeure contre l'usure, barriere chimique et microbiologique contre les infections et agressions exogenes."
        Organes = @("Peau (Epiderme & Derme)", "Oesophage")
        Questions = @(
            @{
                Texte = "Quelle couche de l'epithelium stratifie pavimenteux contient les cellules souches en mitose active ?"
                Choix = @(
                    @{ Texte = "La couche basale (stratum basale ou germinativum)"; EstCorrect = $true },
                    @{ Texte = "La couche cornee (stratum corneum)"; EstCorrect = $false },
                    @{ Texte = "La couche granuleuse (stratum granulosum)"; EstCorrect = $false },
                    @{ Texte = "La couche papillaire profonde"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Dans l'epiderme (keratinise), quelle est la caracteristique cellulaire distinctive de la couche cornee ?"
                Choix = @(
                    @{ Texte = "Cellules aplaties completement anucleees remplies de keratine"; EstCorrect = $true },
                    @{ Texte = "Cellules cubiques vivantes a noyau volumineux"; EstCorrect = $false },
                    @{ Texte = "Presence de nombreuses microvillosites absorbantes"; EstCorrect = $false },
                    @{ Texte = "Proliferation mitotique continue"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle jonction intercellulaire abondante donne a la couche epineuse (stratum spinosum) son aspect epineux ?"
                Choix = @(
                    @{ Texte = "Les desmosomes (macula adherens)"; EstCorrect = $true },
                    @{ Texte = "Les hemi-desmosomes uniquement"; EstCorrect = $false },
                    @{ Texte = "Les synapses chimiques"; EstCorrect = $false },
                    @{ Texte = "Les invaginations mitochondriales"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle cellule pigmentaire localisee dans la couche basale produit la melanine protegeant contre les UV ?"
                Choix = @(
                    @{ Texte = "Le melanocyte"; EstCorrect = $true },
                    @{ Texte = "La cellule de Langerhans"; EstCorrect = $false },
                    @{ Texte = "La cellule de Merkel"; EstCorrect = $false },
                    @{ Texte = "Le mastocyte tissulaire"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle est la principale difference histologique entre l'epithelium de l'oesophage et celui de l'epiderme cutane ?"
                Choix = @(
                    @{ Texte = "L'epithelium oesophagien est stratifie pavimenteux non keratinise (les cellules superficielles gardent leur noyau)"; EstCorrect = $true },
                    @{ Texte = "L'epithelium oesophagien est simple monostratifie"; EstCorrect = $false },
                    @{ Texte = "L'oesophage ne possede pas de membrane basale"; EstCorrect = $false },
                    @{ Texte = "L'oesophage est recouvert de plaques d'hydroxyapatite"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel role jouent les cellules de Langerhans presentes dans l'epithelium stratifie pavimenteux ?"
                Choix = @(
                    @{ Texte = "Cellules presentatrices d'antigenes participant a l'immuno-surveillance cutanee"; EstCorrect = $true },
                    @{ Texte = "Synthese des fibres de collagene tendineux"; EstCorrect = $false },
                    @{ Texte = "Production de sebum cutane"; EstCorrect = $false },
                    @{ Texte = "Contraction pour la vasoconstriction"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel est le temps moyen de renouvellement complet de l'epiderme humain par migration des keratinocytes ?"
                Choix = @(
                    @{ Texte = "Environ 28 a 30 jours (4 semaines)"; EstCorrect = $true },
                    @{ Texte = "Moins de 2 heures"; EstCorrect = $false },
                    @{ Texte = "Plus de 10 annees"; EstCorrect = $false },
                    @{ Texte = "L'epiderme ne se renouvelle jamais apres la naissance"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_05"
        Nom = "Tissu Musculaire Squelettique (Strie)"
        Description = "Tissu contractile compose de volumineux syncytiums cylindriques (rhabdomyocytes) multinuclees a noyaux peripheriques et a striation transversale visible."
        Fonctions = "Contractions puissantes, rapides et volontaires assurant la motricite du squelette, le maintien postural et la production de chaleur."
        Organes = @("Muscle squelettique (Biceps)", "Diaphragme & Langue")
        Questions = @(
            @{
                Texte = "Quelle est la localisation des noyaux dans une fibre musculaire striee squelettique ?"
                Choix = @(
                    @{ Texte = "Multiples et rejetes en peripherie sous la membrane plasmique (sarcolemme)"; EstCorrect = $true },
                    @{ Texte = "Unique et situe strictement au centre de la cellule"; EstCorrect = $false },
                    @{ Texte = "Totalement absents comme dans les hematies"; EstCorrect = $false },
                    @{ Texte = "Localises a l'interieur des tubules T"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle est l'unite contractile elementaire du muscle strie delimitee par deux stries Z ?"
                Choix = @(
                    @{ Texte = "Le sarcomere"; EstCorrect = $true },
                    @{ Texte = "Le sarcolemme"; EstCorrect = $false },
                    @{ Texte = "Le reticulum sarcoplasmique"; EstCorrect = $false },
                    @{ Texte = "Le fascicule musculaire"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelles sont les deux principales proteines myofilamentaires impliquees dans le glissement et le raccourcissement sarcomere ?"
                Choix = @(
                    @{ Texte = "L'actine (filament fin) et la myosine (filament epais)"; EstCorrect = $true },
                    @{ Texte = "La keratine et la tubuline"; EstCorrect = $false },
                    @{ Texte = "L'elastine et le collagene"; EstCorrect = $false },
                    @{ Texte = "L'albumine et la globuline"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel organite specifique stocke et libere massivement les ions calcium necessaires a la contraction musculaire ?"
                Choix = @(
                    @{ Texte = "Le reticulum sarcoplasmique (reticulum endoplasmique lisse specialise)"; EstCorrect = $true },
                    @{ Texte = "L'appareil de Golgi perinucleaire"; EstCorrect = $false },
                    @{ Texte = "Le lysosome primaire"; EstCorrect = $false },
                    @{ Texte = "Le peroxysome"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment se nomme la gaine de tissu conjonctif qui entoure chaque fibre musculaire individuelle ?"
                Choix = @(
                    @{ Texte = "L'endomysium"; EstCorrect = $true },
                    @{ Texte = "Le perimysium"; EstCorrect = $false },
                    @{ Texte = "L'epimysium"; EstCorrect = $false },
                    @{ Texte = "L'epinevre"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle cellule quiescente juxtaposee a la fibre musculaire squelettique permet sa regeneration en cas de lesion ?"
                Choix = @(
                    @{ Texte = "La cellule satellite"; EstCorrect = $true },
                    @{ Texte = "Le mastocyte"; EstCorrect = $false },
                    @{ Texte = "L'osteoclaste"; EstCorrect = $false },
                    @{ Texte = "Le melanocyte"; EstCorrect = $false }
                )
            },
            @{
                Texte = "A quel neurotransmetteur la jonction neuromusculaire (plaque motrice) repond-elle pour declencher la depolarisation ?"
                Choix = @(
                    @{ Texte = "L'acetylcholine"; EstCorrect = $true },
                    @{ Texte = "La dopamine"; EstCorrect = $false },
                    @{ Texte = "Le GABA"; EstCorrect = $false },
                    @{ Texte = "La serotonine"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_06"
        Nom = "Tissu Musculaire Lisse"
        Description = "Cellules fusiformes mononuclees (leiomyocytes) a extremites effilees et a noyau central ovalaire, depourvues de striation transversale evidente."
        Fonctions = "Contractions involontaires, lentes et continues assurant le peristaltisme viscéral, le tonus vasculaire et la motilite des organes creux."
        Organes = @("Paroi digestive (Musculeuse)", "Arteres & Vaisseaux sanguins")
        Questions = @(
            @{
                Texte = "Quelle est la morphologie caracteristique d'une cellule musculaire lisse (leiomyocyte) ?"
                Choix = @(
                    @{ Texte = "Cellule fusiforme effilee a noyau unique et central"; EstCorrect = $true },
                    @{ Texte = "Cylindre multinuclee geant a noyaux peripheriques"; EstCorrect = $false },
                    @{ Texte = "Cellule etoilee ramifiee a disques intercalaires"; EstCorrect = $false },
                    @{ Texte = "Sphere anucleee concave au centre"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Pourquoi le muscle lisse est-il qualifie de 'lisse' au microscope optique ?"
                Choix = @(
                    @{ Texte = "Il ne presente pas de striation transversale car les myofilaments ne sont pas agences en sarcomeres reguliers"; EstCorrect = $true },
                    @{ Texte = "Sa surface externe est depourvue de membrane plasmique"; EstCorrect = $false },
                    @{ Texte = "Il ne contient pas de proteines contractiles"; EstCorrect = $false },
                    @{ Texte = "Il est toujours enrobe de graisse fluide"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle structure d'ancrage cytoplasmique et membranaire remplit dans le muscle lisse le role des stries Z du muscle strie ?"
                Choix = @(
                    @{ Texte = "Les corps denses (dense bodies)"; EstCorrect = $true },
                    @{ Texte = "Les disques intercalaires scalariformes"; EstCorrect = $false },
                    @{ Texte = "Les centrosomes mitotiques"; EstCorrect = $false },
                    @{ Texte = "Les granulations de Nissl"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle proteine regulatrice intracellulaire lie le calcium pour activer la kinase des chaines legeres de myosine (MLCK) ?"
                Choix = @(
                    @{ Texte = "La calmoduline"; EstCorrect = $true },
                    @{ Texte = "La troponine C"; EstCorrect = $false },
                    @{ Texte = "L'albumine serique"; EstCorrect = $false },
                    @{ Texte = "La ferritine"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel type de jonction intercellulaire couple electriquement les cellules musculaires lisses pour synchroniser la contraction peristaltique ?"
                Choix = @(
                    @{ Texte = "Les jonctions communicantes (nexus ou gap junctions)"; EstCorrect = $true },
                    @{ Texte = "Les hemidesmosomes cutanes"; EstCorrect = $false },
                    @{ Texte = "Les synapses dopaminergiques"; EstCorrect = $false },
                    @{ Texte = "Les jonctions d'ancrage cadherines seules"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Par quel systeme nerveux l'activite du muscle lisse est-elle principalement controlee ?"
                Choix = @(
                    @{ Texte = "Le systeme nerveux autonome (vegetatif: sympathique et parasympathique)"; EstCorrect = $true },
                    @{ Texte = "Le cortex moteur volontaire exclusivement"; EstCorrect = $false },
                    @{ Texte = "Le nerf optique"; EstCorrect = $false },
                    @{ Texte = "Le cervelet conscient"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Dans la paroi des arteres de moyen et gros calibre, dans quelle tunique histologique trouve-t-on le muscle lisse ?"
                Choix = @(
                    @{ Texte = "La tunique moyenne (media)"; EstCorrect = $true },
                    @{ Texte = "L'intima"; EstCorrect = $false },
                    @{ Texte = "L'adventice superficielle"; EstCorrect = $false },
                    @{ Texte = "L'endothelium"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_07"
        Nom = "Tissu Cartilagineux (Cartilage Hyalin)"
        Description = "Tissu conjonctif semi-rigide et avasculaire constitue de chondrocytes loges dans des chondroplastes au sein d'une matrice riche en collagene II et proteoglycanes."
        Fonctions = "Soutien elastique des voies respiratoires, glissement articulaire sans friction et matrice de formation du squelette embryonnaire."
        Organes = @("Trachee & Anneaux bronchiques", "Cartilage articulaire")
        Questions = @(
            @{
                Texte = "Quel est le type cellulaire residant mature responsable de l'entretien de la matrice cartilagineuse ?"
                Choix = @(
                    @{ Texte = "Le chondrocyte"; EstCorrect = $true },
                    @{ Texte = "L'osteoclaste"; EstCorrect = $false },
                    @{ Texte = "Le rhabdomyocyte"; EstCorrect = $false },
                    @{ Texte = "Le mastocyte"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment s'appelle la petite logette de la matrice extracellulaire dans laquelle est isole chaque chondrocyte ?"
                Choix = @(
                    @{ Texte = "Le chondroplaste"; EstCorrect = $true },
                    @{ Texte = "Le canal de Havers"; EstCorrect = $false },
                    @{ Texte = "La vacuole pinocytaire"; EstCorrect = $false },
                    @{ Texte = "Le follicule glandulaire"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel type de collagene caracterise specifiquement la matrice du cartilage hyalin ?"
                Choix = @(
                    @{ Texte = "Le collagene de type II"; EstCorrect = $true },
                    @{ Texte = "Le collagene de type I"; EstCorrect = $false },
                    @{ Texte = "Le collagene de type IV"; EstCorrect = $false },
                    @{ Texte = "Le collagene de type VII"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment le cartilage articulaire hyalin assure-t-il sa nutrition en l'absence de perichondre ?"
                Choix = @(
                    @{ Texte = "Par imbibition et diffusion a partir du liquide synovial intra-articulaire"; EstCorrect = $true },
                    @{ Texte = "Par des arteres coronaires penetrantes"; EstCorrect = $false },
                    @{ Texte = "Par des vaisseaux chyliferes lymphatiques"; EstCorrect = $false },
                    @{ Texte = "Par phagocytose des sels mineraux osseux"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment appelle-t-on l'enveloppe conjonctive vascularisee qui borde le cartilage non articulaire (comme dans la trachee) ?"
                Choix = @(
                    @{ Texte = "Le perichondre"; EstCorrect = $true },
                    @{ Texte = "Le perioste"; EstCorrect = $false },
                    @{ Texte = "Le perimysium"; EstCorrect = $false },
                    @{ Texte = "La dure-mere"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle capacite de regeneration autonome possede le tissu cartilagineux adulte chez l'homme ?"
                Choix = @(
                    @{ Texte = "Tres faible a quasi nulle en raison de son avascularite"; EstCorrect = $true },
                    @{ Texte = "Hyper-rapide avec reconstitution complete en 48 heures"; EstCorrect = $false },
                    @{ Texte = "Similaire a celle de la moelle osseuse"; EstCorrect = $false },
                    @{ Texte = "Permanente et sans cicatrice fibreuse"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel polysaccharide sulfate hautement hydrophile constitue le proteoglycane majeur (aggrecane) du cartilage ?"
                Choix = @(
                    @{ Texte = "Le chondroïtine sulfate (associe au keratane sulfate)"; EstCorrect = $true },
                    @{ Texte = "Le glycogene cellulaire"; EstCorrect = $false },
                    @{ Texte = "L'amidon"; EstCorrect = $false },
                    @{ Texte = "La cellulose vegetale"; EstCorrect = $false }
                )
            }
        )
    },
    @{
        Code = "classe_08"
        Nom = "Tissu Osseux (Os Compact & Trabeculaire)"
        Description = "Tissu conjonctif hautement mineralise organise en osteons lamellaires (systemes de Havers) parcourus de canaux vasculaires et renfermant des osteocytes."
        Fonctions = "Charpente rigide du corps, protection des organes nobles, levier locomoteur et reservoir de calcium et phosphate."
        Organes = @("Os long (Femur / Diaphyse)")
        Questions = @(
            @{
                Texte = "Quelle est l'unite structurale et fonctionnelle de base de l'os compact (diaphysaire) ?"
                Choix = @(
                    @{ Texte = "L'osteon (ou systeme de Havers)"; EstCorrect = $true },
                    @{ Texte = "Le sarcomere"; EstCorrect = $false },
                    @{ Texte = "Le follicule primaire"; EstCorrect = $false },
                    @{ Texte = "Le nephron renal"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle est la cellule responsable de la resorption osseuse et du remodelage de la matrice ?"
                Choix = @(
                    @{ Texte = "L'osteoclaste (cellule geante multinucleee)"; EstCorrect = $true },
                    @{ Texte = "L'osteoblaste synthese"; EstCorrect = $false },
                    @{ Texte = "L'osteocyte quiescent"; EstCorrect = $false },
                    @{ Texte = "Le fibroblaste capsulaire"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel sel mineral compose en majorite la phase minerale inorganique de la matrice osseuse ?"
                Choix = @(
                    @{ Texte = "L'hydroxyapatite de calcium [Ca10(PO4)6(OH)2]"; EstCorrect = $true },
                    @{ Texte = "Le chlorure de sodium pur"; EstCorrect = $false },
                    @{ Texte = "Le sulfate de magnesium"; EstCorrect = $false },
                    @{ Texte = "Le bicarbonate de potassium"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Comment communiquent entre eux les osteocytes enfermes dans leurs osteoplastes au sein des lamelles osseuses ?"
                Choix = @(
                    @{ Texte = "Par de fins canalicules osseux reliant leurs prolongements cytoplasmiques"; EstCorrect = $true },
                    @{ Texte = "Par emission de bulles lipidiques"; EstCorrect = $false },
                    @{ Texte = "Par les tubules en T transversaux"; EstCorrect = $false },
                    @{ Texte = "Ils ne communiquent absolument jamais"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quel canal longitudinal au centre de chaque osteon abrite des capillaires sanguins et des fibres nerveuses ?"
                Choix = @(
                    @{ Texte = "Le canal de Havers"; EstCorrect = $true },
                    @{ Texte = "Le canal de Volkmann"; EstCorrect = $false },
                    @{ Texte = "Le canal cochleaire"; EstCorrect = $false },
                    @{ Texte = "Le canal rachidien"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle membrane conjonctive externe richement vascularisee et inervee recouvre la surface externe de l'os (hors cartilage) ?"
                Choix = @(
                    @{ Texte = "Le perioste"; EstCorrect = $true },
                    @{ Texte = "L'endoste"; EstCorrect = $false },
                    @{ Texte = "Le perichondre"; EstCorrect = $false },
                    @{ Texte = "L'epimysium"; EstCorrect = $false }
                )
            },
            @{
                Texte = "Quelle cellule jeune osseuse synthetise activement la fraction organique de la matrice (substance osteoïde) ?"
                Choix = @(
                    @{ Texte = "L'osteoblaste"; EstCorrect = $true },
                    @{ Texte = "L'osteocyte"; EstCorrect = $false },
                    @{ Texte = "L'osteoclaste"; EstCorrect = $false },
                    @{ Texte = "Le chondroblaste"; EstCorrect = $false }
                )
            }
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
                organeIds = $targetOrganeIds
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
            organeIds = $targetOrganeIds
        } | ConvertTo-Json
        $created = Invoke-RestMethod -Uri "http://localhost:5008/api/tissus" -Headers $headers -Method Post -Body $createBody
        $tissuId = $created.id
        Write-Host "  Tissu cree avec succes! ID: $tissuId"
    }

    # Recuperer les questions existantes pour ce tissu
    $existingQuestions = Invoke-RestMethod -Uri "http://localhost:5008/api/questions/tissu/$tissuId" -Headers $headers -Method Get
    Write-Host "  Ce tissu possede actuellement $($existingQuestions.Count) question(s)."

    # Nettoyer si besoin pour avoir exactement 7 questions pedagogiques propres
    if ($existingQuestions.Count -gt 0 -and $existingQuestions.Count -ne 7) {
        Write-Host "  Nettoyage des questions precedentes pour inserer les 7 questions officielles..."
        foreach ($q in $existingQuestions) {
            try {
                Invoke-RestMethod -Uri "http://localhost:5008/api/questions/$($q.id)" -Headers $headers -Method Delete
            } catch {}
        }
        $existingQuestions = @()
    }

    if ($existingQuestions.Count -eq 0) {
        Write-Host "  Insertion de 7 questions QCM..."
        foreach ($qData in $item.Questions) {
            $qBody = @{
                tissuId = $tissuId
                texte = $qData.Texte
                choix = $qData.Choix
            } | ConvertTo-Json -Depth 5

            $resQ = Invoke-RestMethod -Uri "http://localhost:5008/api/questions" -Headers $headers -Method Post -Body $qBody
            $totalQuestionsCreated++
        }
        Write-Host "  -> 7 questions inserees avec succes!"
    } else {
        Write-Host "  -> Le tissu possede deja 7 questions valides."
    }
}

Write-Host "`n========================================================"
Write-Host "INITIALISATION TERMINEE AVEC SUCCES !"
Write-Host "========================================================"
Write-Host "Total questions creees : $totalQuestionsCreated"
