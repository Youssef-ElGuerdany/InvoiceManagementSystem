unit variables;

interface



resourcestring
  SAddSuccess        = '% a été ajouté(e) avec succès.';
  SAddFailed         = '% n''a pas pu être ajouté(e).';
  SAlreadyExists     = '% déjà existe';
  SDeleteSuccess     = '% a été supprimé(e) avec succès.';
  SDeleteFailed      = 'Échec de la suppression';
  SDeleteConfirm     = 'Êtes-vous sûr de vouloir supprimer cet élément ?' ;
  SUpdateSuccess     = 'La mise à jour a été effectuée avec succès';
  SUpdateFailed      = 'Échec de la mise à jour. Veuillez réessayer';


  SDependencyExistsZone = 'Vous ne pouvez pas supprimer cette zone car elle est déjà utilisée dans des enregistrements tiers.';
  SDependencyExistsThirdParty = 'Vous ne pouvez pas supprimer cette entité tiers car elle est déjà utilisée dans des documents.';

  MsgReuiredFields  = 'Veuillez renseigner tous les champs obligatoires avant d''ajouter un %';
  implementation

end.
