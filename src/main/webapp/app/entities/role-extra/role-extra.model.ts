import { BaseEntity } from './../../shared';
import { AppResource } from '../../entities/app-resource/app-resource.model';

export class RoleExtra implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public permissions?: AppResource[],
    ) {
    }
}
